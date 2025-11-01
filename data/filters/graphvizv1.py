#!/usr/bin/env python

"""
Pandoc filter to process code blocks with class "graphviz" into
graphviz-generated images.
"""

import pygraphviz
import hashlib
import os
import sys
from panflute import toJSONFilter, Str, Image, CodeBlock, Figure, Plain, Caption


def sha1(x):
    return hashlib.sha1(x.encode(sys.getfilesystemencoding())).hexdigest()

imagedir = "../output/graphviz"


def graphviz(elem, doc):
    if type(elem) == CodeBlock and 'graphviz' in elem.classes:
        code = elem.text
        try:
            caption = elem.attributes['caption']
        except KeyError:
            caption = 'Add the caption'
        try:
            layout = elem.attributes['layout']
        except KeyError:
            layout = 'neato'
        try:
            directed = bool(elem.attributes['directed'])
        except KeyError:
            directed = True
        try:
            identifier  = elem.identifier 
        except KeyError:
            identifier  = 'figure'
        G = pygraphviz.AGraph(string=code, directed=directed)
        G.layout(prog=layout)
        filename = sha1(code)
        filetype = {'html': 'png', 'latex': 'pdf'}.get(doc.format, 'png')
        alt = Str(caption)
        src = imagedir + '/' + filename + '.' + filetype
        if not os.path.isfile(src):
            try:
                os.makedirs(imagedir, exist_ok=True)
                sys.stderr.write('Created directory ' + imagedir + '\n')
            except OSError:
                pass
            G.draw(src)
            sys.stderr.write('Created image ' + src + '\n')
        image=Image(alt, url=src, title='')
        caption = Caption(Plain(Str(caption)))
        return Figure(Plain(image), caption=caption, identifier=identifier)
def main(doc=None):
    return toJSONFilter(graphviz, doc=doc)

if __name__ == "__main__":
    main()