"""termcolour - terminal colour output tools"""

class TermColour:
    """
    Provides tools for easily outputting strings in colours to the terminal
    Hopefully something like this will end up in bzrlib eventually so it can
    be globally available to everything.
    """

    colours = {
        'black':   '0',
        'red':     '1',
        'green':   '2',
        'yellow':  '3',
        'blue':    '4',
        'magenta': '5',
        'cyan':    '6',
        'white':   '7'}

    def colour_string(self, string, foreground=None, background=None,
                      bright=None):
        """Simple string colouring method"""
        codes = []

        if self.colour_exists(foreground):
            codes.append('3' + self.colours[foreground]);

        if self.colour_exists(background):
            codes.append('4' + self.colours[background]);

        if bright == True:
            codes.append('1');

        if len(codes) > 0:
            return "\033[%sm%s\033[0m" % (';'.join(codes), string);
        else:
            return string

    def colour_exists(self, colour):
        """Return True if the colour passed exists"""
        return self.colours.has_key(colour)
