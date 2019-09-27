# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# https://github.com/Roffild/RoffildLibrary
# ==============================================================================

import re
import sys
from configparser import ConfigParser, DuplicateSectionError, SectionProxy, DuplicateOptionError, \
    _default_dict, _UNSET


def openUnicode(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True,
                opener=None):
    """
    Unicode auto-detection by BOM.
    :return: Returns open() with the correct encoding and with the missing first character, if it is BOM.
    """
    detect = False
    if "r" in mode:
        with open(file, "rb") as f:
            bom = f.read(4)
            detect = True
            if bom[0] == 0xEF and bom[1] == 0xBB and bom[2] == 0xBF:
                encoding = "utf-8"
            elif bom[0] == 0x00 and bom[1] == 0x00 and bom[2] == 0xFE and bom[3] == 0xFF:
                encoding = "utf-32be"
            elif bom[0] == 0xFE and bom[1] == 0xFF:
                encoding = "utf-16be"
            elif bom[0] == 0xFF and bom[1] == 0xFE:
                if bom[2] == 0x00 and bom[3] == 0x00:
                    encoding = "utf-32le"
                else:
                    encoding = "utf-16le"
            else:
                detect = False
    res = open(file=file, mode=mode, buffering=buffering, encoding=encoding, errors=errors, newline=newline,
               closefd=closefd, opener=opener)
    if detect:
        res.read(1)
    return res


def parseMTReport(file, orders=False) -> [()]:
    with openUnicode(file) as report:
        html_tag = re.compile("<[^>]+>")
        center = 0
        result = []
        key = None
        for line in report:
            if center < 2 and r'<td colspan="13" align="center"><div style="font: 10pt Tahoma"><b>' in line:
                center += 1
                continue
            elif r"<td nowrap" in line:
                value = html_tag.sub("", line).strip().rstrip(":")
                if key or "=" in value:
                    result += [(key, value)]
                    key = None
                else:
                    key = value
            elif r"</table>" in line:
                break
        if orders:
            print(__file__, " Orders is not work")
        return result


class WindowsConfigParser(ConfigParser):
    def __init__(self, defaults=None, dict_type=_default_dict,
                 allow_no_value=False, *, delimiters=('=', ':'),
                 comment_prefixes=('#', ';'), inline_comment_prefixes=None,
                 strict=True, empty_lines_in_values=True,
                 default_section='',
                 interpolation=_UNSET, converters=_UNSET):
        super(WindowsConfigParser, self).__init__(defaults=defaults, dict_type=dict_type,
                                                  allow_no_value=allow_no_value, delimiters=delimiters,
                                                  comment_prefixes=comment_prefixes,
                                                  inline_comment_prefixes=inline_comment_prefixes,
                                                  strict=strict, empty_lines_in_values=empty_lines_in_values,
                                                  default_section=default_section,
                                                  interpolation=interpolation, converters=converters)

    def optionxform(self, optionstr):
        return optionstr

    def write(self, fp, space_around_delimiters=False):
        """Write an .ini-format representation of the configuration state.

        If `space_around_delimiters' is True (the default), delimiters
        between keys and values are surrounded by spaces.
        """
        super(WindowsConfigParser, self).write(fp=fp, space_around_delimiters=space_around_delimiters)

    def _write_section(self, fp, section_name, section_items, delimiter):
        """Write a single section to the specified `fp'."""
        if section_name:
            fp.write("[{}]\n".format(section_name))
        for key, value in section_items:
            value = self._interpolation.before_write(self, section_name, key,
                                                     value)
            if value is not None or not self._allow_no_value:
                value = delimiter + str(value).replace('\n', '\n\t')
            else:
                value = ""
            fp.write("{}{}\n".format(key, value))
        fp.write("\n")

    def _read(self, fp, fpname):
        """Parse a sectioned configuration file.

        Each section in a configuration file contains a header, indicated by
        a name in square brackets (`[]'), plus key/value options, indicated by
        `name' and `value' delimited with a specific substring (`=' or `:' by
        default).

        Values can span multiple lines, as long as they are indented deeper
        than the first line of the value. Depending on the parser's mode, blank
        lines may be treated as parts of multiline values or ignored.

        Configuration files may include comments, prefixed by specific
        characters (`#' and `;' by default). Comments may appear on their own
        in an otherwise empty line or may be entered in lines holding values or
        section names.
        """
        elements_added = set()
        cursect = self._defaults
        sectname = None
        optname = None
        indent_level = 0
        e = None  # None, or an exception
        for lineno, line in enumerate(fp, start=1):
            comment_start = sys.maxsize
            # strip inline comments
            inline_prefixes = {p: -1 for p in self._inline_comment_prefixes}
            while comment_start == sys.maxsize and inline_prefixes:
                next_prefixes = {}
                for prefix, index in inline_prefixes.items():
                    index = line.find(prefix, index + 1)
                    if index == -1:
                        continue
                    next_prefixes[prefix] = index
                    if index == 0 or (index > 0 and line[index - 1].isspace()):
                        comment_start = min(comment_start, index)
                inline_prefixes = next_prefixes
            # strip full line comments
            for prefix in self._comment_prefixes:
                if line.strip().startswith(prefix):
                    comment_start = 0
                    break
            if comment_start == sys.maxsize:
                comment_start = None
            value = line[:comment_start].strip()
            if not value:
                if self._empty_lines_in_values:
                    # add empty line to the value, but only if there was no
                    # comment on the line
                    if (comment_start is None and
                            cursect is not None and
                            optname and
                            cursect[optname] is not None):
                        cursect[optname].append('')  # newlines added at join
                else:
                    # empty line marks end of value
                    indent_level = sys.maxsize
                continue
            # continuation line?
            first_nonspace = self.NONSPACECRE.search(line)
            cur_indent_level = first_nonspace.start() if first_nonspace else 0
            if (cursect is not None and optname and
                    cur_indent_level > indent_level):
                cursect[optname].append(value)
            # a section header or option header?
            else:
                indent_level = cur_indent_level
                # is it a section header?
                mo = self.SECTCRE.match(value)
                if mo:
                    sectname = mo.group('header')
                    if sectname in self._sections:
                        if self._strict and sectname in elements_added:
                            raise DuplicateSectionError(sectname, fpname,
                                                        lineno)
                        cursect = self._sections[sectname]
                        elements_added.add(sectname)
                    elif sectname == self.default_section:
                        cursect = self._defaults
                    else:
                        cursect = self._dict()
                        self._sections[sectname] = cursect
                        self._proxies[sectname] = SectionProxy(self, sectname)
                        elements_added.add(sectname)
                    # So sections can't start with a continuation line
                    optname = None
                # an option line?
                else:
                    mo = self._optcre.match(value)
                    if mo:
                        optname, vi, optval = mo.group('option', 'vi', 'value')
                        if not optname:
                            e = self._handle_error(e, fpname, lineno, line)
                        optname = self.optionxform(optname.rstrip())
                        if (self._strict and
                                (sectname, optname) in elements_added):
                            raise DuplicateOptionError(sectname, optname,
                                                       fpname, lineno)
                        elements_added.add((sectname, optname))
                        # This check is fine because the OPTCRE cannot
                        # match if it would set optval to None
                        if optval is not None:
                            optval = optval.strip()
                            cursect[optname] = [optval]
                        else:
                            # valueless option handling
                            cursect[optname] = None
                    else:
                        # a non-fatal parsing error occurred. set up the
                        # exception but keep going. the exception will be
                        # raised at the end of the file and will contain a
                        # list of all bogus lines
                        e = self._handle_error(e, fpname, lineno, line)
        self._join_multiline_values()
        # if any parsing errors occurred, raise an exception
        if e:
            raise e
