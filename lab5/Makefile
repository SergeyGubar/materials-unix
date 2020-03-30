all:
	gcc -o pzpi-16-3-hubar-serhii-lab5.out pzpi-16-3-hubar-serhii-lab5.c

install:
	./configure.sh
	gcc -o pzpi-16-3-hubar-serhii-lab5.out pzpi-16-3-hubar-serhii-lab5.c
	./install.sh

uninstall:
	make clean
	rm ${HOME}/bin/pzpi-16-3-hubar-serhii-lab5.out

clean:
	rm *.out || true
	rm *.log || true

run:
	gcc -o pzpi-16-3-hubar-serhii-lab5.out pzpi-16-3-hubar-serhii-lab5.c
	./pzpi-16-3-hubar-serhii-lab5.out