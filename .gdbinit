set disassembly-flavor intel
set print pretty on
set pagination off
set confirm off

python
import splitmind
(splitmind.Mind()
  .tell_splitter(show_titles=True)
  .tell_splitter(set_title="Main")
  .right(of="main", display="regs", size="20%")
  .tell_splitter(set_title="Registers")
  .above(of="main", display="code", size="75%")
  .tell_splitter(set_title="Source code")
  .left(of="code", display="backtrace", size="30%")
  .tell_splitter(set_title="Calls")
  .below(of="backtrace", display="legend", size="70%")
  .show("stack", on="legend")
  .tell_splitter(set_title="Stack")
  .below(of="code", display="disasm", size="50%")
  .tell_splitter(set_title="Disassembly")
).build(nobanner=True)
end

python
import gdb
class StepBeforeNextCall (gdb.Command):
    def __init__ (self):
        super (StepBeforeNextCall, self).__init__ ("sb",
                                                   gdb.COMMAND_OBSCURE)

    def invoke (self, arg, from_tty):
        arch = gdb.selected_frame().architecture()

        while True:
            current_pc = addr2num(gdb.selected_frame().read_register("pc"))
            disa = arch.disassemble(current_pc)[0]
            if "call" in disa["asm"]: # or startswith ?
                break

            SILENT=True
            gdb.execute("stepi", to_string=SILENT)

def addr2num(addr):
    try:
        return int(addr)  # Python 3
    except:
        return long(addr) # Python 2

StepBeforeNextCall()
end
