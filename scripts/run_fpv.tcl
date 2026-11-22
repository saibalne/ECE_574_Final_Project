set_fml_appmode FPV

set top     axil_fv_top
set defines ""
set tag     "baseline"
if {[info exists env(FV_DEFINES)]} { set defines $env(FV_DEFINES) }
if {[info exists env(FV_TAG)]}     { set tag     $env(FV_TAG) }
file mkdir results/$tag

# ---- Compile and elaborate the RTL and formal environment -------------------
read_file -top $top -format sverilog -sva \
          -vcs "-sverilog -f scripts/filelist.f $defines"

# ---- Formal clock and reset -------------------------------------------------
create_clock aclk -period 100
create_reset aresetn -sense low

# Simulate reset, then use the post-reset state as the formal initial state.
sim_run -stable
sim_save_reset

# ---- Prove assertions and search for cover witnesses -----------------------
check_fv -block

# ---- Reports ---------------------------------------------------------------
report_fv -list    > results/$tag/fpv_list.txt
report_fv          > results/$tag/fpv_summary.txt

puts "INFO: results written to results/$tag/"
