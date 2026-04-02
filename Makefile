DC      := ldc2
DFLAGS  := -g -I$(SRC_DIR)
SRC_DIR := src
BLD_DIR := build

SRC  := $(wildcard $(SRC_DIR)/**/*.d)
OBJ  := $(patsubst $(SRC_DIR)/%.d, $(BLD_DIR)/%.o, $(SRC))
DEPS := $(OBJ:.o=.deps)
TARGET := ngc.a

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJ)
	ar rcs $@ $^

$(BLD_DIR)/%.o: $(SRC_DIR)/%.d
	@mkdir -p $(dir $@)
	$(DC) $(DFLAGS) -c -makedeps=$(@:.o=.deps) -of=$@ $<
# NOTE: flag "-makedeps" does not work properly with dmd, hence using dmd is unsupported.
-include $(DEPS)

clean:
	rm -rf $(BLD_DIR) $(TARGET)
