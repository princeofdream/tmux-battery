

all:
	$(CXX) scripts/battery.cpp -o scripts/tmux_battery


clean:
	rm -rf tmux_sysstat
