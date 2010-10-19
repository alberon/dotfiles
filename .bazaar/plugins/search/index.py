# search, a bzr plugin for searching within bzr branches/repositories.
# Copyright (C) 2008 Robert Collins
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as published
# by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# 

"""The core logic for search."""

from bisect import bisect_left
from itertools import chain
import math
import re

from bzrlib import branch as _mod_branch
from bzrlib import ui
from bzrlib.btree_index import BTreeGraphIndex, BTreeBuilder
from bzrlib.bzrdir import BzrDirMeta1
import bzrlib.config
from bzrlib.errors import NotBranchError, NoSuchFile, UnknownFormatError
from bzrlib.index import CombinedGraphIndex, GraphIndex, InMemoryGraphIndex
from bzrlib.lockdir import LockDir
try:
    from bzrlib.osutils import md5
except ImportError:
    from md5 import new as md5
from bzrlib.osutils import split_lines
from bzrlib.pack import ContainerWriter
from bzrlib.plugins.search import errors
from bzrlib.plugins.search.inventory import paths_from_ids
from bzrlib.plugins.search.transport import FileView
from bzrlib.multiparent import NewText
from bzrlib.revision import NULL_REVISION
xml_serializers = []
try:
    from bzrlib.xml4 import _Serializer_v4
    xml_serializers.append(_Serializer_v4)
except ImportError:
    pass
try:
    from bzrlib.xml5 import Serializer_v5
    xml_serializers.append(Serializer_v5)
except ImportError:
    pass
try:
    from bzrlib.xml6 import Serializer_v6
    xml_serializers.append(Serializer_v6)
except ImportError:
    pass
try:
    from bzrlib.xml7 import Serializer_v7
    xml_serializers.append(Serializer_v7)
except ImportError:
    pass
try:
    from bzrlib.xml8 import Serializer_v8
    xml_serializers.append(Serializer_v8)
except ImportError:
    pass
from bzrlib.transport import get_transport
from bzrlib.tsort import topo_sort

_FORMAT_1 = 'bzr-search search folder 1\n'
_FORMAT_2 = 'bzr-search search folder 2\n'
# _FORMATS definitions are the end of the module, so that they can use index
# subclasses.
_tokeniser_re = None


def _ensure_regexes():
    global _tokeniser_re
    if _tokeniser_re is None:
        # NB: Perhaps we want to include non-ascii, or is there some unicode
        # magic to generate good terms? (Known to be a hard problem, but this
        # is sufficient for an indexer that may not even live a week!)
        _tokeniser_re = re.compile("[^A-Za-z0-9_]")


def init_index(branch, format_number=2):
    """Initialise an index on branch.
    
    :param format_number: The index format to create. Currently 1 by default.
    """
    if isinstance(branch.bzrdir, BzrDirMeta1):
        transport = branch.bzrdir.transport
        transport.mkdir('bzr-search')
        index_transport = transport.clone('bzr-search')
    else:
        # We don't know how to handle this format.
        try:
            from bzrlib.plugins.svn.branch import SvnBranch
        except ImportError:
            SvnBranch = None
        if type(branch) != SvnBranch:
            raise errors.CannotIndex(branch)
        # We can't write to the 'bzrdir' as it is virtual
        uuid = branch.repository.uuid
        branch_path = branch.get_branch_path()
        config = bzrlib.config.config_dir()
        transport = get_transport(bzrlib.config.config_dir())
        path = 'bzr-search/svn-lookaside/' + uuid + '/' + branch_path
        paths = path.split('/')
        for path in paths:
            transport = transport.clone(path)
            transport.ensure_base()
        index_transport = transport
    lockdir = LockDir(index_transport, 'names-lock')
    lockdir.create()
    lockdir.lock_write()
    try:
        if format_number == 1:
            format = _FORMAT_1
        elif format_number == 2:
            format = _FORMAT_2
        else:
            raise Exception("unknown format number %s" % format_number)
        index_transport.put_bytes('format', format)
        names_list = _FORMATS[format][0](0, 1)
        index_transport.put_file('names', names_list.finish())
        index_transport.mkdir('obsolete')
        index_transport.mkdir('indices')
        index_transport.mkdir('upload')
    finally:
        lockdir.unlock()
    return open_index_url(branch.bzrdir.root_transport.base)


def index_url(url):
    """Create or update an index at url.

    :param url: The url to index.
    :return: The resulting search index.
    """
    branch = _mod_branch.Branch.open(url)
    branch.lock_read()
    try:
        _last_revid = branch.last_revision()
        try:
            index = open_index_url(url)
            index.index_branch(branch, _last_revid)
        except errors.NoSearchIndex:
            index = init_index(branch)
            graph =  branch.repository.get_graph()
            searcher = graph._make_breadth_first_searcher([_last_revid])
            revs_to_index = set()
            while True:
                try:
                    next_revs, ghosts = searcher.next_with_ghosts()
                except StopIteration:
                    break
                revs_to_index.update(next_revs)
            if NULL_REVISION in revs_to_index:
                revs_to_index.remove(NULL_REVISION)
            index.index_revisions(branch, revs_to_index)
    finally:
        branch.unlock()
    return index


def open_index_url(url):
    """Open a search index at url.

    :param url: The url to open the index from.
    :return: A search index.
    :raises: NoSearchIndex if no index can be located.
    """
    try:
        branch = _mod_branch.Branch.open(url)
    except NotBranchError:
        raise errors.NoSearchIndex(url)
    return open_index_branch(branch)


def open_index_branch(branch):
    """Open a search index at a branch.

    This could do look-aside stuff for svn branches etc in the future.
    :param branch: The branch to get an index for.
    :raises: NoSearchIndex if no index can be located.
    """
    try:
        from bzrlib.plugins.svn.branch import SvnBranch
    except ImportError:
        SvnBranch = None
    if type(branch) == SvnBranch:
        # We can't write to the 'bzrdir' as it is virtual
        uuid = branch.repository.uuid
        branch_path = branch.get_branch_path()
        config = bzrlib.config.config_dir()
        transport = get_transport(bzrlib.config.config_dir())
        path = 'bzr-search/svn-lookaside/' + uuid + '/' + branch_path
        transport = transport.clone(path)
        commits_only = False
    else:
        transport = branch.bzrdir.transport.clone('bzr-search')
        commits_only = False
    return Index(transport, branch, commits_only=commits_only)


# XXX: This wants to be a PackCollection subclass with RepositoryPackCollection
# being a sibling. For now though, copy and paste FTW.
class Index(object):
    """A bzr content index.
    
    :ivar _format: The format tuple - see _FORMATS.
    """

    def __init__(self, index_transport, branch, commits_only=False):
        """Create an index stored at index_transport.

        :param index_transport: The path where the index data should be stored.
        :param branch: The branch this Index is indexing.
        :param commits_only: If True, when indexing only attempt to index
            commits, not file texts. Useful for foreign formats (often commits
            are the most mature part of such plugins), or for some projects
            where file contents may not be useful to index.
        """
        self._transport = index_transport
        try:
            format = self._transport.get_bytes('format')
        except NoSuchFile:
            raise errors.NoSearchIndex(index_transport)
        self._upload_transport = self._transport.clone('upload')
        self._obsolete_transport = self._transport.clone('obsolete')
        self._indices_transport = self._transport.clone('indices')
        try:
            self._format = _FORMATS[format]
        except KeyError:
            raise UnknownFormatError(format, 'bzr-search')
        self._orig_names = {}
        self._current_names = {}
        self._revision_indices = []
        self._term_doc_indices = {}
        self._revision_index = CombinedGraphIndex(self._revision_indices)
        # because terms may occur in many component indices, we don't use a 
        # CombinedGraphIndex for grouping the term indices or doc indices.
        self._lock = LockDir(index_transport, 'names-lock')
        self._branch = branch
        self._commits_only = commits_only

    def _add_terms(self, index, terms):
        """Add a set of term posting lists to a in progress index.

        A term is a single index key (e.g. ('first',)).
        A posting list is an iterable of full index keys (e.g.
        ('r', '', REVID) for a revision, or ('t', FILEID, REVID) for a file
        text.)

        :param index: A ComponentIndexBuilder.
        :param terms: An iterable of term -> posting list.
        """
        for term, posting_list in terms:
            index.add_term(term, posting_list)

    def all_terms(self):
        """Return an iterable of all the posting lists in the index.

        :return: An iterator of (term -> document ids).
        """
        self._refresh_indices()
        result = {}
        for value, component in self._current_names.values():
            terms = component.all_terms()
            for term, posting_list in terms.iteritems():
                result.setdefault(term, set()).update(posting_list)
        return result.iteritems()

    def _document_ids_to_keys(self, document_ids):
        """Expand document ids to keys.

        :param document_ids: An iterable of (index, doc_id) tuples.
        :result: An iterable of document keys.
        """
        indices = {}
        # group by index
        for index, doc_id in document_ids:
            doc_ids = indices.setdefault(index, set())
            doc_ids.add((doc_id,))
        for index, doc_ids in indices.items():
            doc_index = self._term_doc_indices[index]
            for node in doc_index.iter_entries(doc_ids):
                yield tuple(node[2].split(' ', 2))

    def index_branch(self, branch, tip_revision):
        """Index revisions from a branch.

        :param branch: The branch to index.
        :param tip_revision: The tip of the branch.
        """
        branch.lock_read()
        try:
            graph =  branch.repository.get_graph()
            searcher = graph._make_breadth_first_searcher([tip_revision])
            self._refresh_indices()
            revision_index = self._revision_index
            revs_to_index = set()
            while True:
                try:
                    next_revs, ghosts = searcher.next_with_ghosts()
                except StopIteration:
                    break
                else:
                    rev_keys = [(rev,) for rev in next_revs]
                    indexed_revs = set([node[1][0] for node in
                        revision_index.iter_entries(rev_keys)])
                    unindexed_revs = next_revs - indexed_revs
                    searcher.stop_searching_any(indexed_revs)
                revs_to_index.update(unindexed_revs)
            if NULL_REVISION in revs_to_index:
                revs_to_index.remove(NULL_REVISION)
            self.index_revisions(branch, revs_to_index)
        finally:
            branch.unlock()

    def index_revisions(self, branch, revisions_to_index):
        """Index some revisions from branch.
        
        :param branch: A branch to index.
        :param revisions_to_index: A set of revision ids to index.
        """
        branch.lock_read()
        try:
            outer_bar = ui.ui_factory.nested_progress_bar()
            try:
                return self._index_revisions(branch, revisions_to_index,
                    outer_bar)
            finally:
                outer_bar.finished()
        finally:
            branch.unlock()

    def _index_revisions(self, locked_branch, revisions_to_index, outer_bar):
        """Helper for indexed_revisions."""
        if not revisions_to_index:
            return
        _ensure_regexes()
        graph = locked_branch.repository.get_graph()
        parent_map = graph.get_parent_map(revisions_to_index)
        order = topo_sort(parent_map)
        order_dict = {}
        for pos, revid in enumerate(order):
            order_dict[revid] = pos
        # 5000 uses 1GB on a mysql tree.
        # Testing shows 1500 or so is a sweet spot for bzr, 2500 for python - ideally this wouldn't matter.
        # Interesting only 2 times reduction in memory was observed every down
        # at a group of 50, though it does slowly grow as it increases.
        group_size = 2000
        groups = len(order) / group_size + 1
        for offset in range(groups):
            outer_bar.update("Indexing...", offset, groups)
            revision_group = order[offset * group_size:(offset + 1) * group_size]
            builder = ComponentIndexBuilder(self._format)
            # here: index texts
            # here: index inventory/paths
            # here: index revisions
            steps = ui.ui_factory.nested_progress_bar()
            try:
                steps.update("Indexing texts", 0, 4)
                if not self._commits_only:
                    terms = self._terms_for_texts(locked_branch.repository,
                        revision_group)
                    self._add_terms(builder, terms)
                    steps.update("Indexing paths", 1, 4)
                    terms = self._terms_for_file_terms(
                        locked_branch.repository, terms, order_dict)
                    self._add_terms(builder, terms)
                steps.update("Indexing commits", 2, 4)
                terms = self._terms_for_revs(locked_branch.repository,
                    revision_group)
                self._add_terms(builder, terms)
                for rev_id in revision_group:
                    builder.add_revision(rev_id)
                steps.update("Saving group", 3, 4)
                self._add_index(builder)
            finally:
                steps.finished()

    def _add_index(self, builder, to_remove=None, allow_pack=True):
        """Add a new component index to the list of indices.
        
        :param builder: A component builder supporting the upload_index call.
        :param to_remove: An optional iterable of components to remove.
        :param allow_pack: Whether an auto pack is permitted by this operation.
        """
        # The index name is the md5sum of the revision index serialised form.
        index_name, index_value, elements = builder.upload_index(
            self._upload_transport)
        if index_name in self._current_names:
            raise Exception("md5 collision! rad! %s" % index_name)
        # The component is uploaded, we only need to rename to activate.
        self._lock.lock_write()
        try:
            self._refresh_indices(to_remove=to_remove)
            if index_name in self._current_names:
                raise Exception(
                    "md5 collision with concurrent writer! rad! %s" % index_name)
            # Serialise the index list
            new_names = self._format[0](0, 1)
            new_names.add_node((index_name,), index_value, ())
            for name, (value, index) in self._current_names.items():
                new_names.add_node((name,), value, ())
            # Now, as the last step, rename the new index into place and update
            # the disk list of names.
            for element in elements:
                self._upload_transport.rename(element,
                    '../indices/' + element)
            self._transport.put_file('names', new_names.finish())
            index = ComponentIndex(self._format, index_name, index_value,
                self._indices_transport)
            self._orig_names[index_name] = (index_value, index)
            # Cleanup obsoleted if needed, if we are removing things.
            if to_remove:
                self._obsolete_transport.delete_multi(
                    self._obsolete_transport.list_dir('.'))
        finally:
            self._lock.unlock()
        # Move any no-longer-referenced packs out of the indices to the
        # obsoleted area.
        if to_remove:
            for component in to_remove:
                relpath = component.name + '.pack'
                self._indices_transport.rename(relpath,
                    '../obsolete/' + relpath)
        # Add in-memory
        self._add_index_to_memory(index_name, index_value, index)
        # Its safely inserted. Trigger a pack ?
        if not allow_pack:
            return
        total_revisions = self._revision_index.key_count()
        max_components = int(math.ceil(math.log(total_revisions, 2)))
        if max_components < 1:
            max_components = 1
        excess = len(self._current_names) - max_components
        if excess < 1:
            return
        old_components = []
        for name, (value, component) in self._current_names.iteritems():
            old_components.append((component.revision_index.key_count(), name))
        old_components.sort()
        del old_components[excess + 1:]
        components = [self._current_names[name][1] for length, name in
            old_components]
        # Note: we don't recurse here because of two things:
        # B) we don't want to regress infinitely; a flag to _add_index would do
        # this.
        # C) We need to remove components too.
        combiner = ComponentCombiner(self._format, components,
            self._upload_transport)
        self._add_index(combiner, to_remove=components, allow_pack=False)
        
    def _add_index_to_memory(self, name, value, index):
        """Add an index (with meta-value value) to the in-memory index list."""
        self._current_names[name] = (value, index)
        self._revision_indices.append(index.revision_index)
        self._term_doc_indices[index] = index.document_index

    def indexed_revisions(self):
        """Return the revision_keys that this index contains terms for."""
        self._refresh_indices()
        for node in self._revision_index.iter_all_entries():
            yield node[1]

    def _refresh_indices(self, to_remove=None):
        """Merge on-disk index lists into the memory top level index list.
        
        :param to_remove: An optional list of components to remove from memory
            even if they are still listed on disk.
        """
        names = self._format[1](self._transport, 'names', None)
        new_names = {}
        merged_names = {}
        deleted_names = set()
        if to_remove:
            for component in to_remove:
                deleted_names.add(component.name)
        added_names = set()
        same_names = set()
        for node in names.iter_all_entries():
            name = node[1][0]
            value = node[2]
            new_names[name] = [value, None]
        for name in new_names:
            if name not in self._orig_names:
                added_names.add(name)
            elif name in self._current_names:
                same_names.add(name)
            else:
                # in our last read; not in memory anymore:
                deleted_names.add(name)
                # XXX perhaps cross-check the size?
        for name in added_names:
            # TODO: byte length of the indices here.
            value = new_names[name][0]
            component = ComponentIndex(self._format, name, value,
                self._indices_transport)
            self._add_index_to_memory(name, value, component)
        for name in deleted_names:
            self._remove_component_from_memory(name)
        self._orig_names = new_names

    def _remove_component_from_memory(self, name):
        """Remove the component name from the index list in memory."""
        index = self._current_names[name][1]
        del self._term_doc_indices[index]
        self._revision_indices.remove(index.revision_index)
        del self._current_names[name]

    def _search_work(self, termlist):
        """Core worker logic for performing searches.
        
        :param termlist: An iterable of terms to search for.
        :return: An iterator over (component, normalised_termlist,
            matching_document_keys). Components where the query does not hit
            anytthing are not included in the iterator. Using an empty query
            results in all components being returned but no document keys being
            listed for each component.
        """
        _ensure_regexes()
        self._refresh_indices()
        # Use a set to remove duplicates
        new_termlist = set()
        exclude_terms = set()
        for term in termlist:
            if term[0][0] == '-':
                # exclude this term
                exclude_terms.add((term[0][1:],) + term[1:])
            else:
                new_termlist.add(term)
        # remove duplicates that were included *and* excluded
        termlist = new_termlist - exclude_terms
        term_keys = [None, set(), set()]
        for term in termlist:
            term_keys[len(term)].add(term)
        for term in exclude_terms:
            term_keys[len(term)].add(term)

        for value, component in self._current_names.values():
            term_index = component.term_index
            # TODO: push into Component
            found_term_count = 0
            # TODO: use dequeues?
            term_info = []
            exclude_info = []
            for node in chain(term_index.iter_entries(term_keys[1]),
                component.term_2_index.iter_entries(term_keys[2])):
                term_id, posting_count, posting_start, posting_length = \
                    node[2].split(" ")
                info  = (int(posting_count), term_id, int(posting_start),
                    int(posting_length))
                if node[1] not in exclude_terms:
                    term_info.append(info)
                    found_term_count += 1
                else:
                    exclude_info.append(info)
                    excluded = 1
            if not termlist:
                yield component, termlist, None
                continue
            if len(term_info) != len(termlist):
                # One or more terms missing - no hits are possible.
                continue
            # load the first document list: 
            term_info.sort()
            _, term_id, posting_start, posting_length = term_info.pop(0)
            posting_stop = posting_start + posting_length
            post_name = "term_list." + term_id
            filemap = {post_name:(posting_start, posting_stop)}
            view = FileView(self._indices_transport, component.name + '.pack',
                filemap)
            post_index = self._format[1](view, post_name, posting_length)
            common_doc_keys = set([node[1] for node in
                post_index.iter_all_entries()])
            # Now we whittle down the nodes we need - still going in sorted
            # order. (possibly doing concurrent reduction would be better).
            while common_doc_keys and term_info:
                common_doc_keys = self._select_doc_keys(common_doc_keys,
                    term_info.pop(0), component)
            if common_doc_keys:
                # exclude from largest-first, which should give us less
                # exclusion steps.
                exclude_info.sort(reverse=True)
                while common_doc_keys and exclude_info:
                    common_doc_keys.difference_update(self._select_doc_keys(
                        common_doc_keys, exclude_info.pop(0), component))
            yield component, termlist, common_doc_keys

    def search(self, termlist):
        """Trivial set-based search of the index.

        :param termlist: A list of terms.
        :return: An iterator of SearchResults for documents indexed by all
            terms in the termlist.
        """
        found_documents = []
        if not termlist:
            return
        for component, termlist, common_doc_keys in self._search_work(termlist):
            common_doc_ids = [key[0] for key in common_doc_keys]
            found_documents = [(component, doc_id) for doc_id in
                common_doc_ids]
            for doc_key in self._document_ids_to_keys(found_documents):
                if doc_key[0] == 'f':
                    # file text
                    yield FileTextHit(self, self._branch.repository,
                        doc_key[1:3], termlist)
                elif doc_key[0] == 'r':
                    # revision
                    yield RevisionHit(self._branch.repository, doc_key[2:3])
                elif doc_key[0] == 'p':
                    # path
                    yield PathHit(doc_key[2])
                else:
                    raise Exception("unknown doc type %r" % (doc_key,))

    def _select_doc_keys(self, key_filter, term_info, component):
        """Select some document keys from a term.

        :param key_filter: An iterable of document keys to constrain the
            search.
        :param term_info: The index metadata about the terms posting list.
        :param component: The component being searched within.
        """
        _, term_id, posting_start, posting_length = term_info
        posting_stop = posting_start + posting_length
        post_name = "term_list." + term_id
        filemap = {post_name:(posting_start, posting_stop)}
        view = FileView(self._indices_transport,
            component.name + '.pack', filemap)
        post_index = self._format[1](view, post_name, posting_length)
        return set([node[1] for node in post_index.iter_entries(key_filter)])

    def suggest(self, termlist):
        """Generate suggestions for extending a search.

        :param termlist: A list of terms.
        :return: An iterator of terms that start with the last search term in
            termlist, and match the rest of the search.
        """
        found_documents = []
        if not termlist:
            return
        suggest_term = termlist[-1]
        suggestions = set()
        for component, termlist, common_doc_keys in self._search_work(termlist[:-1]):
            if len(suggest_term) == 1:
                suggest_index = component.term_index
            else:
                suggest_index = component.term_2_index
            for node in suggest_index.iter_entries_starts_with(suggest_term):
                suggestion = node[1]
                if common_doc_keys:
                    term_id, posting_count, posting_start, posting_length = \
                        node[2].split(" ")
                    posting_count = int(posting_count)
                    posting_start = int(posting_start)
                    posting_length = int(posting_length)
                    posting_stop = posting_start + posting_length
                    post_name = "term_list." + term_id
                    filemap = {post_name:(posting_start, posting_stop)}
                    view = FileView(self._indices_transport,
                        component.name + '.pack', filemap)
                    post_index = self._format[1](view, post_name, posting_length)
                    common_doc_keys = set([node[1] for node in
                        post_index.iter_entries(common_doc_keys)])
                    if len(common_doc_keys):
                        # This suggestion matches other terms in the qury:
                        suggestions.add(suggestion)
                else:
                    suggestions.add(suggestion)
        return suggestions

    def _terms_for_file_terms(self, repository, file_terms, order_dict):
        """Generate terms for the path of every file_id, revision_id in terms.

        :param repository: The repository to access inventories from.
        :param terms: Text terms than have been inserted.
        :param order_dict: A mapping from revision id to order from the
            topological sort prepared for the indexing operation.
        :return: An iterable of (term, posting_list) for the file_id,
            revision_id pairs mentioned in terms.
        """
        terms = {}
        # What revisions do we need inventories for:
        revision_ids = {}
        for term, posting_list in file_terms:
            for post in posting_list:
                if post[0] != 'f':
                    raise ValueError("Unknown post type for %r" % post)
                fileids = revision_ids.setdefault(post[2], set())
                fileids.add(post[1])
        order = list(revision_ids)
        order.sort(key=lambda revid:order_dict[revid])
        group_size = 100
        groups = len(order) / group_size + 1
        bar = ui.ui_factory.nested_progress_bar()
        try:
            for offset in range(groups):
                bar.update("Extract revision paths", offset, groups)
                inventory_group = order[offset * group_size:(offset + 1) * group_size]
                serializer = repository._serializer
                if type(serializer) in xml_serializers:
                    # Fast path for flat-file serializers.
                    group_keys = [(revid,) for revid in inventory_group]
                    stream = repository.inventories.get_record_stream(
                        group_keys, 'unordered', True)
                    for record in stream:
                        bytes = record.get_bytes_as('fulltext')
                        revision_id = record.key[-1]
                        path_dict = paths_from_ids(bytes, serializer,
                            revision_ids[revision_id])
                        for file_id, path in path_dict.iteritems():
                            terms[(file_id, revision_id)] = [('p', '', path)]
                else:
                    # Public api way - 5+ times slower on xml inventories
                    for inventory in repository.iter_inventories(inventory_group):
                       revision_id = inventory.revision_id
                       for file_id in revision_ids[revision_id]:
                           path = inventory.id2path(file_id)
                           terms[(file_id, revision_id)] = [('p', '', path)]
        finally:
            bar.finished()
        return terms.iteritems()

    def _terms_for_revs(self, repository, revision_ids):
        """Generate the posting list for the revision texts of revision_ids.

        :param revision_ids: An iterable of revision_ids.
        :return: An iterable of (term, posting_list) for the revision texts
            (not the inventories or user texts) of revision_ids.
        """
        terms = {}
        for revision in repository.get_revisions(revision_ids):
            # its a revision, second component is ignored, third is id.
            document_key = ('r', '', revision.revision_id)
            # components of a revision:
            # parents - not indexed (but we could)
            # commit message (done)
            # author (todo)
            # committer (todo)
            # properties (todo - names only?)
            # bugfixes (a property we know how to read)
            # other filters?
            message_utf8 = revision.message.encode('utf8')
            commit_terms = _tokeniser_re.split(message_utf8)
            for term in commit_terms:
                if not term:
                    continue
                posting_list = terms.setdefault((term,), set())
                posting_list.add(document_key)
        return terms.iteritems()

    def _terms_for_texts(self, repository, revision_ids):
        """Generate the posting list for the file texts of revision_ids.

        :param revision_ids: An iterable of revision_ids.
        :return: An iterable of (term, posting_list) for the revision texts
            (not the inventories or user texts) of revision_ids.
        """
        terms = {}
        files = {}
        for item in repository.item_keys_introduced_by(revision_ids):
            if item[0] != 'file':
                continue
            # partitions the files by id, to avoid serious memory overload.
            file_versions = files.setdefault(item[1], set())
            for file_version in item[2]:
                file_versions.add((item[1], file_version))
        for file_id, file_keys in files.iteritems():
            file_keys = list(file_keys)
            group_size = 100
            groups = len(file_keys) / group_size + 1
            for offset in range(groups):
                file_key_group = file_keys[offset * group_size:(offset + 1) * group_size]
                for diff, key in zip(repository.texts.make_mpdiffs(file_key_group),
                    file_key_group):
                    document_key = ('f',) + key
                    for hunk in diff.hunks:
                        if type(hunk) == NewText:
                            for line in hunk.lines:
                                line_terms = _tokeniser_re.split(line)
                                for term in line_terms:
                                    if not term:
                                        continue
                                    posting_list = terms.setdefault((term,), set())
                                    posting_list.add(document_key)
        return terms.items()


class FileTextHit(object):
    """A match found during a search in a file text."""

    def __init__(self, index, repository, text_key, termlist):
        """Create a FileTextHit.

        :param index: The index the search result is from, to look up the path
            of the hit. NB
        :param repository: A repository to extract revisions from.
        :param text_key: The text_key that was hit.
        :param termlist: The query that was issued, used for generating
            summaries.
        """
        self.index = index
        self.repository = repository
        self.text_key = text_key
        self.termlist = termlist

    def document_name(self):
        """The name of the document found, for human consumption."""
        # Perhaps need to utf_decode this?
        path = self.index.search((self.text_key,)).next()
        return "%s in revision '%s'." % (path.document_name(), self.text_key[1])

    def summary(self):
        """Get a summary of the hit, for display to users."""
        lines = self.repository.iter_files_bytes([
            (self.text_key[0], self.text_key[1], "")]).next()[1]
        if not isinstance(lines, list):
            # We got bytes back, not lines (which the contract supports).
            lines = split_lines(lines)
        # We could look for the best match, try to get context, line numbers
        # etc. This is complex - what if 'foo' is on line 1 and 'bar' on line
        # 54.
        # NB: This does not handle phrases correctly - but - make it work.
        flattened_terms = set([' '.join(term) for term in self.termlist])
        for line in lines:
            line_terms = set(_tokeniser_re.split(line))
            if len(line_terms.intersection(flattened_terms)) > 0:
                return line[:-1].decode('utf8', 'replace')
        raise ValueError("no match? wtf? %r" % lines)


class PathHit(object):
    """A match found during a search in a file path."""

    def __init__(self, path_utf8):
        """Create a PathHit.

        :param path_utf8: The path (utf8 encoded).
        """
        self.path_utf8 = path_utf8

    def document_name(self):
        """The name of the document found, for human consumption."""
        return self.path_utf8.decode("utf8")

    def summary(self):
        """Get a summary of the hit."""
        return self.document_name()


class RevisionHit(object):
    """A match found during a search in a revision object."""

    def __init__(self, repository, revision_key):
        """Create a RevisionHit.

        :param repository: A repository to extract revisions from.
        :param revision_key: The revision_key that was hit.
        """
        self.repository = repository
        self.revision_key = revision_key

    def document_name(self):
        """The name of the document found, for human consumption."""
        # Perhaps need to utf_decode this?
        return "Revision id '%s'." % self.revision_key[0]

    def summary(self):
        """Get a summary of the revision."""
        # Currently, just the commit first line.
        revision = self.repository.get_revision(self.revision_key[-1])
        return revision.message.splitlines()[0]


class ComponentIndex(object):
    """A single component in the aggregate search index.

    Components are a single pack containing:
    The relevant files are:
     - an index listing indexed revisions (name.rix)
     - an index mapping terms to posting lists (name.tix)
     - an index mapping document ids to document keys (name.dix)
     - A posting-list per term (name.N) listing the document ids the term
       indexes.

    The index implementation is selected from the format tuple.
    """

    def __init__(self, format, name, value, transport):
        """Create a ComponentIndex.

        :param format: The format object for this bzr-search folder.
        :param name: The name of the index.
        :param value: The value string from the names list for this component.
        """
        lengths = value.split(' ')
        lengths = [int(length) for length in lengths]
        filemap = {
            "revisions": (lengths[0], lengths[0] + lengths[1]),
            "terms": (lengths[2], lengths[2] + lengths[3]),
            "documents": (lengths[4], lengths[4] + lengths[5]),
            "terms_2": (lengths[6], lengths[6] + lengths[7]),
            }
        self._format = format
        view = FileView(transport, name + '.pack', filemap)
        rev_index = self._format[1](view, "revisions", lengths[1])
        term_index = self._format[1](view, "terms", lengths[3])
        term_2_index = self._format[1](view, "terms_2", lengths[7])
        doc_index = self._format[1](view, "documents", lengths[5])
        self.revision_index = rev_index
        self.term_index = term_index
        self.term_2_index = term_2_index
        self.document_index = doc_index
        self.name = name
        self.transport = transport

    def all_terms(self):
        """As per Index, but for a single component."""
        result = {}
        for node in chain(self.term_index.iter_all_entries(),
            self.term_2_index.iter_all_entries()):
            # XXX: Duplicated logic with search().
            term = node[1]
            term_id, posting_count, posting_start, posting_length = \
                node[2].split(" ")
            posting_count = int(posting_count)
            posting_start = int(posting_start)
            posting_length = int(posting_length)
            posting_stop = posting_start + posting_length
            post_name = "term_list." + term_id
            filemap = {post_name:(posting_start, posting_stop)}
            view = FileView(self.transport, self.name + '.pack', filemap)
            post_index = self._format[1](view, post_name, posting_length)
            doc_ids = set([node[1] for node in
                post_index.iter_all_entries()])
            posting_list = set(self._document_ids_to_keys(doc_ids))
            result[term] = posting_list
        return result

    def _document_ids_to_keys(self, doc_ids):
        """Expand document ids to keys.

        :param document_ids: An iterable of doc_id tuples.
        :result: An iterable of document keys.
        """
        indices = {}
        for node in self.document_index.iter_entries(doc_ids):
            yield tuple(node[2].split(' ', 2))

    def indexed_revisions(self):
        """Return the revision_keys that this index contains terms for."""
        for node in self.revision_index.iter_all_entries():
            yield node[1]


class ComponentCreator(object):
    """Base class for classes that create ComponentIndices."""
    
    def add_document(self, document_key):
        """Add a document key to the index.

        :param document_key: A document key e.g. ('r', '', 'some-rev-id').
        :return: The document id allocated within this index.
        """
        if document_key in self._document_ids:
            return self._document_ids[document_key]
        next_id = str(self.document_index.key_count())
        self.document_index.add_node((next_id,), "%s %s %s" % document_key, ())
        self._document_ids[document_key] = next_id
        return next_id

    def _add_index_to_pack(self, index, name, writer, index_bytes=None):
        """Add an index to a pack.

        This ensures the index is encoded as plain bytes in the pack allowing
        arbitrary readvs.

        :param index: The index to write to the pack.
        :param name: The name of the index in the pack.
        :param writer: a ContainerWriter.
        :param index_bytes: Optional - the contents of the serialised index.
        :return: A start, length tuple for reading the index back from the
            pack.
        """
        if index_bytes is None:
            index_file = index.finish()
            index_bytes = index_file.read()
            del index_file
        pos, size = writer.add_bytes_record(index_bytes, [(name,)])
        length = len(index_bytes)
        offset = size - length
        start = pos + offset
        return start, length


class ComponentIndexBuilder(ComponentCreator):
    """Creates a component index."""

    def __init__(self, format):
        self.document_index = format[0](0, 1)
        self._document_ids = {}
        self.terms = {}
        self.revision_index = format[0](0, 1)
        self.posting_lists = {}
        self._format = format

    def add_term(self, term, posting_list):
        """Add a term to the index.

        :param term: A term, e.g. ('foo',).
        :param posting_list: A list of the document_key's that this term
            indexes.
        :return: None.
        """
        if type(term) != tuple:
            raise ValueError("terms need to be tuples %r" % term)
        for component in term:
            if type(component) != str:
                raise ValueError(
                    "terms must be bytestrings at this layer %r" % term)
        term_id = self.term_id(term)
        if term_id is None:
            term_id = str(len(self.terms))
            self.terms[term] = term_id
            self.posting_lists[term_id] = set()
        existing_posting_list = self.posting_lists[term_id]
        for document_key in posting_list:
            existing_posting_list.add(self.add_document(document_key))

    def add_revision(self, revision_id):
        """List a revision as having been indexed by this index."""
        self.revision_index.add_node((revision_id,), '',  ())

    def posting_list(self, term):
        """Return an iterable of document ids for term.

        Unindexed terms return an empty iterator.
        """
        term_id = self.term_id(term)
        if term_id is None:
            return []
        else:
            return self.posting_lists[term_id]

    def term_id(self, term):
        """Return the term id of term. 

        :param term: The term to get an id for.
        :return: None for a term not in the component, otherwise the string
            term id.
        """
        try:
            return self.terms[term]
        except KeyError:
            return None

    def upload_index(self, upload_transport):
        """Upload the index in preparation for insertion.

        :param upload_transport: The transport to upload to.
        :return: The index name, the value for the names list, and a list of
            the filenames that comprise the index.
        """
        # Upload preparatory to renaming into place.
        # write to disc.
        index_file = self.revision_index.finish()
        index_bytes = index_file.read()
        del index_file
        index_name = md5(index_bytes).hexdigest()
        write_stream = upload_transport.open_write_stream(index_name + ".pack")
        writer = ContainerWriter(write_stream.write)
        writer.begin()
        rev_start, rev_length = self._add_index_to_pack(self.revision_index,
            "revisions", writer, index_bytes)
        del index_bytes
        # generate a new term index with the length of the serialised posting
        # lists.
        term_indices = {}
        term_indices[1] = self._format[0](0, 1)
        term_indices[2] = self._format[0](0, 2)
        for term, term_id in self.terms.iteritems():
            posting_list = self.posting_lists[term_id]
            post_index = self._format[0](0, 1)
            for doc_id in posting_list:
                post_index.add_node((doc_id,), "", ())
            posting_name = "term_list." + term_id
            start, length = self._add_index_to_pack(post_index, posting_name,
                writer)
            # The below can be factored out and reused with the
            # ComponentCombiner if we get rid of self.terms and use terms
            # directly until we serialise the posting lists, rather than
            # assigning ids aggressively.
            # How many document ids, and the range for the file view when we
            # read the pack later.
            term_value = "%s %d %d %d" % (term_id, len(posting_list), start,
                length)
            term_indices[len(term)].add_node(term, term_value, ())
        term_start, term_length = self._add_index_to_pack(term_indices[1],
            "terms", writer)
        term_2_start, term_2_length = self._add_index_to_pack(term_indices[2],
            "terms2", writer)
        doc_start, doc_length = self._add_index_to_pack(self.document_index,
            "documents", writer)
        writer.end()
        write_stream.close()
        index_value = "%d %d %d %d %d %d %d %d" % (rev_start, rev_length,
            term_start, term_length, doc_start, doc_length, term_2_start,
            term_2_length)
        elements = [index_name + ".pack"]
        return index_name, index_value, elements


class ComponentCombiner(ComponentCreator):
    """Combines components into a new single larger component."""

    def __init__(self, format, components, transport):
        """Create a combiner.

        :param format: The format of component to create.
        :param components: An iterable of components.
        :param transport: A transport to upload the combined component to.
        :return: A tuple - the component name, the value for the names file,
            and the elements list for the component.
        """
        self.components = list(components)
        self.transport = transport
        self._format = format
    
    def _copy_documents(self):
        """Copy the document references from components to a new component.
        
        This popules self.component_docid with the mappings from each
        component's document ids to the output document ids.
        """
        self._document_ids = {}
        self.document_index = self._format[0](0, 1)
        self.component_docids = {}
        for component in self.components:
            component_docs = {}
            self.component_docids[component] = component_docs
            for node in component.document_index.iter_all_entries():
                # duplication with _document_ids_to_keys
                document_key = tuple(node[2].split(' ', 2))
                doc_id = self.add_document(document_key)
                # Map from the old doc id to the new doc it
                component_docs[node[1]] = doc_id
        self.doc_start, self.doc_length = self._add_index_to_pack(
            self.document_index, "documents", self.writer)
        # Clear out used objects
        del self._document_ids
        del self.document_index

    def _copy_posting_lists(self):
        """Copy the posting lists from components to the new component.
        
        This uses self.component_docid to map document ids across efficiently,
        and self.terms to determine what to copy from.
        It populates self.term_index as it progresses.
        """
        term_indices = {1:self._format[0](0, 1),
            2:self._format[0](0, 2)
            }
        for term, posting_lists in self.terms.iteritems():
            posting_list = set()
            for component, posting_line in posting_lists:
                elements = posting_line.split(' ')
                _, term_id, posting_start, posting_length = elements
                posting_start = int(posting_start)
                posting_length = int(posting_length)
                posting_stop = posting_start + posting_length
                post_name = "term_list." + term_id
                filemap = {post_name:(posting_start, posting_stop)}
                view = FileView(component.transport,
                    component.name + '.pack', filemap)
                post_index = self._format[1](view, post_name, posting_length)
                doc_mapping = self.component_docids[component]
                for node in post_index.iter_all_entries():
                    posting_list.add(doc_mapping[node[1]])
            post_index = self._format[0](0, 1)
            for doc_id in posting_list:
                post_index.add_node((doc_id,), '', ())
            term_id = str(term_indices[1].key_count() +
                term_indices[2].key_count())
            start, length = self._add_index_to_pack(
                post_index, "term_list." + term_id, self.writer)
            # How many document ids, and the range for the file view when we
            # read the pack later.
            term_value = "%s %d %d %d" % (term_id, len(posting_list), start,
                length)
            term_indices[len(term)].add_node(term, term_value, ())
        self.term_indices = term_indices
        # Clear out used objects
        del self.terms
        del self.component_docids

    def _copy_revisions(self):
        """Copy the revisions from components to a new component.
        
        This also creates the writer.
        """
        # Merge revisions:
        revisions = set()
        for component in self.components:
            for node in component.revision_index.iter_all_entries():
                revisions.add(node[1])
        revision_index = self._format[0](0, 1)
        for revision in revisions:
            revision_index.add_node(revision, '', ())
        index_file = revision_index.finish()
        index_bytes = index_file.read()
        del index_file
        self.index_name = md5(index_bytes).hexdigest()
        self.write_stream = self.transport.open_write_stream(
            self.index_name + ".pack")
        self.writer = ContainerWriter(self.write_stream.write)
        self.writer.begin()
        self.rev_start, self.rev_length = self._add_index_to_pack(
            revision_index, "revisions", self.writer, index_bytes)

    def combine(self):
        """Combine the components."""
        # Note on memory pressue: deleting the source index caches
        # as soon as they are copied would reduce memory pressure.
        self._copy_revisions()
        self._copy_documents()
        self._scan_terms()
        self._copy_posting_lists()
        self.term_start, self.term_length = self._add_index_to_pack(
            self.term_indices[1], "terms", self.writer)
        self.term_2_start, self.term_2_length = self._add_index_to_pack(
            self.term_indices[2], "terms2", self.writer)
        self.writer.end()
        self.write_stream.close()
        index_value = "%d %d %d %d %d %d %d %d" % (self.rev_start,
            self.rev_length, self.term_start, self.term_length, self.doc_start,
            self.doc_length, self.term_2_start, self.term_2_length)
        elements = [self.index_name + ".pack"]
        return self.index_name, index_value, elements

    def _scan_terms(self):
        """Scan the terms in all components to prepare to copy posting lists."""
        self.terms = {}
        for component in self.components:
            for node in chain(component.term_index.iter_all_entries(),
                    component.term_2_index.iter_all_entries()):
                term = node[1]
                posting_info = node[2]
                term_set = self.terms.setdefault(term, set())
                term_set.add((component, posting_info))

    def upload_index(self, upload_transport):
        """Thunk for use by Index._add_index."""
        self.transport = upload_transport
        return self.combine()


class SuggestableGraphIndex(GraphIndex):
    """A subclass of GraphIndex which adds starts_with searches.

    These searches are used for providing suggestions.
    """

    def iter_entries_starts_with(self, key):
        """Iterate over nodes which match key.

        The first length()-1 terms in key must match exactly, and the last term
        in key is used as a starts_with test.

        :param key: The key to search with.
        """
        # Make it work:
        # Partly copied from iter_entries()
        # PERFORMANCE TODO: parse and bisect all remaining data at some
        # threshold of total-index processing/get calling layers that expect to
        # read the entire index to use the iter_all_entries  method instead.
        half_page = self._transport.recommended_page_size() // 2
        # For when we don't know the length to permit bisection, or when the
        # index is fully buffered in ram.
        if self._size is None or self._nodes is not None:
            if len(key) > 1:
                candidates = self.iter_entries_prefix([key[:-1] + (None,)])
            else:
                candidates = self.iter_all_entries()
            for candidate in candidates:
                if candidate[1][-1].startswith(key[-1]):
                    yield candidate
        else:
            # Bisect to find the start.
            # TODO: If we know a reasonable upper bound we could do one IO for
            # the remainder.
            # loop parsing more until wwe have one range covering the
            # suggestions.
            step = self._size //2
            search = [(step, key)]
            found = self._lookup_keys_via_location(search)
            while True:
                step = step // 2
                if found[0][1] not in [-1, 1]:
                    # We can now figure out where to start answering from.
                    break
                search = [(found[0][0][0] + step * found[0][1], key)]
                found = self._lookup_keys_via_location(search)
            while True:
                if self._nodes:
                    # we triggered a full read - everything is in _nodes now.
                    for result in self.iter_entries_starts_with(key):
                        yield result
                    return
                lower_index = self._parsed_key_index(key)
                parsed_range = self._parsed_key_map[lower_index]
                last_key = parsed_range[1]
                if last_key[:-1] > key[:-1]:
                    # enough is parsed
                    break
                if last_key[:-1] == key[:-1]:
                    if (last_key[-1] > key[-1] and not
                        last_key[-1].startswith(key[-1])):
                        # enough is parsed
                        break
                hi_parsed = self._parsed_byte_map[lower_index][1]
                if hi_parsed == self._size:
                    # all parsed
                    break
                next_probe = hi_parsed + half_page - 1
                if lower_index + 1 < len(self._parsed_byte_map):
                    next_bottom = self._parsed_byte_map[lower_index +1][0]
                    if next_bottom <= next_probe:
                        # read before the parsed area
                        next_probe = next_bottom - 800
                self._read_and_parse([(next_probe, 800)])
            # Now, scan for all keys in the potential range, and test them for
            # being candidates, yielding if they are.
            if self.node_ref_lists:
                raise ValueError("TODO: implement resolving of reference lists"
                    " on starts_with searches.")
            lower_index = self._parsed_key_index(key)
            parsed_range = self._parsed_byte_map[lower_index]
            for offset, candidate_node in self._keys_by_offset.iteritems():
                if offset < parsed_range[0] or offset >= parsed_range[1]:
                    continue
                candidate_key = candidate_node[0]
                if (candidate_key[:-1] == key[:-1] and
                    candidate_key[-1].startswith(key[-1])):
                    if self.node_ref_lists:
                        value, refs = self._bisect_nodes[candidate_key]
                        yield (self, candidate_key, value,
                            self._resolve_references(refs))
                    else:
                        value = self._bisect_nodes[candidate_key]
                        yield (self, candidate_key, value)


class SuggestableBTreeGraphIndex(BTreeGraphIndex):
    """A subclass of BTreeGraphIndex which adds starts_with searches.

    These searches are used for providing suggestions.
    """

    def iter_entries_starts_with(self, key):
        """Iterate over nodes which match key.

        The first length()-1 terms in key must match exactly, and the last term
        in key is used as a starts_with test.

        :param key: The key to search with.
        """
        if not self.key_count():
            return

        # The lowest node to read in the next row.
        low_index = 0
        # the highest node to read in the next row.
        high_index = 0
        # Loop down the rows, setting low_index to the lowest node in the row
        # that we need to read, and high_index to the highest.

        key_prefix = key[:-1]
        key_suffix = key[-1]

        lower_key = key
        higher_key = key_prefix + (key_suffix[:-1] + chr(ord(key_suffix[-1]) + 1),)

        for row_pos, next_row_start in enumerate(self._row_offsets[1:-1]):
            # find the lower node and higher node bounding the suggestion range
            node_indices = set([low_index, high_index])
            nodes = self._get_internal_nodes(node_indices)
            # Lower edge
            low_node = nodes[low_index]
            position = bisect_left(low_node.keys, lower_key)
            node_offset = next_row_start + low_node.offset
            low_index = node_offset + position
            # Higher edge
            high_node = nodes[high_index]
            position = bisect_left(high_node.keys, higher_key)
            node_offset = next_row_start + high_node.offset
            high_index = node_offset + position
        # We should now be at the _LeafNodes
        node_indices = range(low_index, high_index + 1)

        # TODO: We may *not* want to always read all the nodes in one
        #       big go. Consider setting a max size on this.

        group_size = 100
        groups = len(node_indices) / group_size + 1
        for offset in range(groups):
            node_group = node_indices[offset * group_size:(offset + 1) * group_size]
            nodes = self._get_leaf_nodes(node_group)
            for node in nodes.values():
                # TODO bisect the edge nodes? / find boundaries and so skip
                # some work.
                items = sorted(node.keys.items())
                low_value = (key, ())
                start_pos = bisect_left(items, low_value)
                for pos in xrange(start_pos, len(items)):
                    node_key, (value, refs) = items[pos]
                    if node_key[:-1] != key_prefix:
                        # Shouldn't happen, but may.
                        continue
                    if not node_key[-1].startswith(key_suffix):
                        # A node that doesn't match
                        if node_key[-1] > key_suffix:
                            # and is after: stop
                            break
                        else:
                            # was before the search start point.
                            continue
                    if self.node_ref_lists:
                        yield (self, node_key, value, refs)
                    else:
                        yield (self, node_key, value)


_original_make_search_filter = None


def make_disable_search_filter(branch, generate_delta, search, log_rev_iterator):
    """Disable search filtering if bzr-search will be active.

    This filter replaces the default search filter, using the original filter
    if a bzr-search filter cannot be used.

    :param branch: The branch being logged.
    :param generate_delta: Whether to generate a delta for each revision.
    :param search: A user text search string.
    :param log_rev_iterator: An input iterator containing all revisions that
        could be displayed, in lists.
    :return: An iterator over ((rev_id, revno, merge_depth), rev, delta).
    """
    try:
        open_index_branch(branch)
        query = query_from_regex(search)
        if query:
            return log_rev_iterator
    except errors.NoSearchIndex:
        pass
    return _original_make_search_filter(branch, generate_delta, search,
        log_rev_iterator)


def make_log_search_filter(branch, generate_delta, search, log_rev_iterator):
    """Filter revisions by using a search index.

    This filter looks up revids in the search index along with the search
    string, if the search string regex can be converted into a bzr-search
    query.

    :param branch: The branch being logged.
    :param generate_delta: Whether to generate a delta for each revision.
    :param search: A user text search string.
    :param log_rev_iterator: An input iterator containing all revisions that
        could be displayed, in lists.
    :return: An iterator over ((rev_id, revno, merge_depth), rev, delta).
    """
    # Can we possibly search on this regex?
    query = query_from_regex(search)
    if not query:
        return log_rev_iterator
    try:
        index = open_index_branch(branch)
    except errors.NoSearchIndex:
        return log_rev_iterator
    return _filter_log(index, query, log_rev_iterator)


def _filter_log(index, query, log_rev_iterator):
    """Filter log_rev_iterator's revision ids on query in index."""
    rev_ids = set()
    # TODO: we could lazy evaluate the search, for each revision we see - this
    # would allow searches that hit everything to be less-than-completely
    # evaluated before the first result is shown. OTOH knowing a miss will
    # require reading the entire search anyhow. Note that we can do better -
    # if we looked up the document id of the revision, we could search explicitly
    # for the document id in the search up front, and do many small searches. This is
    # likely better in terms of memory use. Needs refactoring etc.
    for result in index.search(query):
        if type(result) != RevisionHit:
            continue
        rev_ids.add(result.revision_key[0])
    for batch in log_rev_iterator:
        new_revs = []
        for item in batch:
            if item[0][0] in rev_ids:
                new_revs.append(item)
        yield new_revs


def query_from_regex(regex):
    """Convert a regex into a bzr-search query."""
    # Most trivial implementation ever
    if not regex:
        return None
    if regex.count("\\b") != 2:
        return None
    regex = regex[2:-2]
    if regex.count("\\b") != 0:
        return None
    # Any additional whitespace implies something we can't search on:
    _ensure_regexes()
    if _tokeniser_re.search(regex):
        return None
    return [(regex,)]


_FORMATS = {
    # format: index builder, index reader, index deletes
    _FORMAT_1:(InMemoryGraphIndex, SuggestableGraphIndex, False),
    _FORMAT_2:(BTreeBuilder, SuggestableBTreeGraphIndex, True)
    }
