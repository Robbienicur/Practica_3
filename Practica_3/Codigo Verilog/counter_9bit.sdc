create_clock -name CLOCK_50 -period 20.000 [get_ports CLOCK_50]
derive_clock_uncertainty
# Entradas asincronas (botones/switch): ya se sincronizan con 2 FF en el diseno
set_false_path -from [get_ports {BTN_RESET_N BTN_PAUSE_N BTN_INC_N BTN_DEC_N SW_FREQ[*]}]
