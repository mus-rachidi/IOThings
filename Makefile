.PHONY: all p1 p2 p3 bonus clean vm

all: p1 p2 p3 bonus vm

vm:
	cd vm && vagrant up

p1:
	cd p1 && vagrant up

p2:
	cd p2 && vagrant up

p3:
	cd p3 && ./scripts/config.sh && sleep 10 && ./scripts/run.sh

bonus:
	cd bonus && ./scripts/config.sh && sleep 10 && ./scripts/run.sh

clean:
	cd p1 && vagrant destroy -f
	cd p2 && vagrant destroy -f
	# rm -f p1/confs/node-token p1/.vagrant
	# rm -f p2/confs/node-token p1/.vagrant