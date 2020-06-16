#
# Makefile for CCS Project 1 - Forest Fire
#

#
# Location of the processing programs
#
RASM = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.map

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -m -o $*.out $*.obj > $*.map

#
# Object Files
#
OBJECTS = forestfire.obj generate.obj
OBJECTS2 = forestfire2.obj generate.obj

#
# Main Target
#
forestfire.out: $(OBJECTS)
	$(RLINK) -m -o forestfire.out $(OBJECTS) > forestfire.map

forestfire2.out: $(OBJECTS2)
	$(RLINK) -m -o forestfire2.out $(OBJECTS2) > forestfire2.map
