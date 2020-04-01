all:
	chmod +x ./configure.sh
	./configure.sh
	gcc -pthread -o pzpi-16-3-hubar-serhii-lab5.out pzpi-16-3-hubar-serhii-lab5.c

install:
	chmod +x ./install.sh
	./install.sh

uninstall:
	make clean
	rm ${HOME}/bin/pzpi-16-3-hubar-serhii-lab5.out

clean:
	rm *.out || true
	rm *.log || true

run:
	gcc -pthread -o pzpi-16-3-hubar-serhii-lab5.out pzpi-16-3-hubar-serhii-lab5.c
	./pzpi-16-3-hubar-serhii-lab5.out

archive:
	tar -czvf pzpi-16-3-hubar-serhii-lab5.tar.gz Makefile configure.sh install.sh pzpi-16-3-hubar-serhii-lab5.c README.md