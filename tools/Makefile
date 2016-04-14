
CC = gcc
CXX = g++

all: DonorSim intersection merge_variation splitfasta vcf_del verify-deletion
DonorSim:
	$(CC) DonorSim.c -o DonorSim
intersection:
	$(CXX) intersection.cpp -o intersection
merge_variation:
	$(CXX) merge_variation.cpp -o merge_variation
splitfasta:
	$(CC) splitfasta.c -o splitfasta
vcf_del:
	$(CC) vcf_del.c -o vcf_del
verify-deletion:
	$(CC) verify-deletion.c -o verify-deletion
	
clean:
	rm DonorSim intersection merge_variation splitfasta vcf_del verify-deletion

.PHONY: clean
