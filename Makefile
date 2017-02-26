# .PHONY
# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
# a phony target is one that is not really the name of a file

# Automatic Variables
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
# $@ the file name of the target rurle
# $< the first prerequisite

# VPATH
# https://www.gnu.org/software/make/manual/html_node/General-Search.html
# VPATH specifies a list of directories that make should search.

# https://www.gnu.org/software/make/manual/html_node/Setting.html
# Simply expanded variables
#  var := value
# Recursively expanded variables
#  var = value
# Conditional variable assignment operator
#  var ?= value
#  It only has an effect if the variable is not yet defined.

# Syntax of Conditionals
# https://www.gnu.org/software/make/manual/html_node/Conditional-Syntax.html
# ifeq (a, b)
# ifneq (a, b)
# endif



OBJ_DIR         = ./obj
DEPEND_FILE     = Makefile.d

CXXFLAGS        += -c -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_GNU_SOURCE
# Bruce Evans' BDE options
CXXFLAGS        += -Wall -W -Wno-format-y2k -Wpointer-arith -Wreturn-type -Wcast-qual -Wwrite-strings -Wunused-result
CXXFLAGS        += -Wswitch -Wshadow -Wcast-align -Wuninitialized -Wformat=2
CFLAGS          += -Wstrict-prototypes -Wmissing-prototypes

RELEASE_FLAGS   = -O3 -DNDEBUG
DEBUG_FLAGS     = -O3 -g -DDEBUG

TARGET          = ./a.out

LDFLAGS         +=
ifneq ($(strip $(CXX_SRCS)), "")
 LDFLAGS         += -lstdc++ -lpthread
endif
#LDFLAGS         += -Wl,--version-script,version.map 
INCLUDE_FLAGS   = -I common

#CMD_PREFIX      = arm-none-linux-gnueabi-
CMD_PREFIX      =
STRIP           = $(CMD_PREFIX)strip
CC              = $(CMD_PREFIX)gcc
CXX             = $(CMD_PREFIX)g++
AR              = $(CMD_PREFIX)ar
MAKE            = $(CMD_PREFIX)make
VPATH           = $(OBJ_DIR)

ifeq ($(strip $(RELEASE)), y)
 CXXFLAGS       += $(RELEASE_FLAGS)
else
 CXXFLAGS       += $(DEBUG_FLAGS) 
endif

CXXFLAGS        += $(INCLUDE_FLAGS)
CFLAGS          += $(CXXFLAGS)

CXX_SRCS        = $(shell find . -name "*.cpp") $(shell find . -name "*.cc")
SRCS            = $(shell find . -name "*.c")
OBJS            = $(subst .cpp,.o,$(subst .cc,.o,$(CXX_SRCS))) $(subst .c,.o,$(SRCS))

.PHONY: all
all: depend $(OBJS)
	$(CXX) $(addprefix $(OBJ_DIR)/, $(OBJS)) $(LDFLAGS) -o $(TARGET)

.PHONY: release
release:
	@$(MAKE) -f Makefile RELEASE=y all

.PHONY: clean
clean: depend_clean
	@rm -rf $(OBJ_DIR) $(TARGET)

.PHONY: depend
depend: depend_clean
ifneq ($(strip $(CXX_SRCS)),)
	@$(CXX) $(CXXFLAGS) -M $(CXX_SRCS) >> $(DEPEND_FILE)
endif
ifneq ($(strip $(SRCS)),)
	@$(CC) $(CFLAGS) -M $(SRCS) >> $(DEPEND_FILE)
endif

.PHONY: depend_clean
depend_clean:
	@rm -rf ./$(DEPEND_FILE)

.SUFFIXES: .c .cpp .cc .o
.cpp.o:
	@mkdir -p $(OBJ_DIR)/$(dir $@)
	$(CXX) $(CXXFLAGS) $< -o $(OBJ_DIR)/$@

.cc.o:
	@mkdir -p $(OBJ_DIR)/$(dir $@)
	$(CXX) $(CXXFLAGS) $< -o $(OBJ_DIR)/$@

.c.o:
	@mkdir -p $(OBJ_DIR)/$(dir $@)
	$(CC) $(CFLAGS) $< -o $(OBJ_DIR)/$@

-include $(DEPEND_FILE)
