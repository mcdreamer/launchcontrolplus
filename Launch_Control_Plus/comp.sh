#!/usr/bin/python

import os, sys
import py_compile
import compileall

def main():
    if len(sys.argv) < 2:
		print "usage: compileall tree ..."
		return 0
    else:
		for dir in sys.argv[1:]:
		    print "compiling %s" % dir
		    compileall.compile_dir(dir)
		return 1

if __name__ == '__main__':
    exit_status = not main()
    sys.exit(exit_status)
