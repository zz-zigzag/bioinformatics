#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <map>
#include <string>

using namespace std;

#define PACKAGE_VERSION "0.0.1"

static int usage()
{
    fprintf(stderr, "\n");
    fprintf(stderr, "Program: intersection (find the intersection in result of various caller.)\n");
    fprintf(stderr, "Version: %s\n", PACKAGE_VERSION);
    fprintf(stderr, "Contact: zz_zigzag <zz_zigzag@outlook.com>\n\n");
    fprintf(stderr, "Usage:   intersection [option] <in_file> <out_file>\n");
    fprintf(stderr, "         The input format is [chrom start end label] and sorted by chrom and start\n");
    fprintf(stderr, "Options: -n INT   minimum number of intersected sets.[2]\n");
    fprintf(stderr, "         -e FLOAT maximum percent deviation of breakpoint (-e*sv_length) [0.4]\n");
    fprintf(stderr, "         -m INT   maximum base deviation of breakpoint [200]\n");
    fprintf(stderr, "         -s STR   label of callers in priorities. [pindel/svseq/delly/breakdancer]\n");
    return 1;
}

int getFileRowsNumber(char *filename)
{
   char *sys = (char *)malloc(strlen(filename) + 10);
   sprintf(sys,"wc -l %s", filename);
   FILE *fp = popen(sys, "r");
   int n;
   if(fscanf(fp, "%d", &n) != 1)
       exit(1);
   pclose(fp);
   return n;
}

void openFile(FILE **file, char *filename,const char *type)
{
   if((*file = fopen(filename, type)) == NULL)
   {
       perror(filename);
       exit(1);
   }
   return ;
}

typedef struct {
    char chr[100], caller[100];
    int brk1, brk2;
    int cntSameVar;
    int pSameVar;
    int index;
    bool isCovered;      // there is some var same to this, but precise breakpoint prefer others.
}variation;


int main(int argc, char* argv[])
{
    char c;
    int n = 2;
    double e = 0.4;
    int m = 200;
    char defaultString[100] = {"pindel/svseq/delly/breakdancer"};
    char *labelString = defaultString;
    while((c = getopt(argc, argv, "s:n:e:m:")) != EOF) {
        switch(c) {
            case 'n': n = atoi(optarg); break;
            case 'e': e = atof(optarg); break;
            case 'm': m = atoi(optarg); break;
            case 's': labelString = optarg; break;
        }
    }
    if(argc - optind != 2) return usage();
    char *save, *strLabel;
    save = strLabel = NULL;
    int i = 0;
    map <string, int> label;
    while((strLabel = strtok_r(labelString, "/", &save)) != NULL) {
        string str = strLabel;
        label[str] = i++;
        labelString = NULL;
    }


    FILE *fpin, *fpout;
    openFile(&fpin, argv[optind], "r");
    openFile(&fpout, argv[optind+1], "w");
    int varCnt = getFileRowsNumber(argv[optind]);
    variation *var = (variation *)malloc(varCnt * sizeof(variation));

    i = 0;
    int diff;
    while(fscanf(fpin, "%s%d%d%s", var[i].chr, &var[i].brk1, &var[i].brk2, var[i].caller) !=EOF) {
        var[i].isCovered = false;
        var[i].cntSameVar = 1;
        var[i].pSameVar=i;
        string str = var[i].caller;
        var[i].index = label[str];
        diff = e * (var[i].brk2 - var[i].brk1);
        if (diff > m) diff = m;
        for(int j = i - 1; j >= 0; --j) {
            if (var[i].brk1 - var[j].brk1 > diff) break;
            else if (abs(var[i].brk2 - var[j].brk2) <= diff) {
                if (var[j].isCovered) continue;
                if (var[i].index == var[j].index && var[j].cntSameVar == 1) continue;
                if (var[i].index != var[j].index) var[j].cntSameVar++;
                else if (var[j].pSameVar < j) continue;

                if (var[i].index <= var[j].index) {
                    var[i].cntSameVar = var[j].cntSameVar;
                    var[j].isCovered = true;
                }
                else {
                    var[i].isCovered = true;
                }
                var[j].pSameVar = i;
                var[i].pSameVar = j;
            }
        }
        ++i;
    }
    varCnt = i;
    for (i = 0; i < varCnt; ++i) {
        if (!var[i].isCovered && var[i].cntSameVar >= n) {
            fprintf(fpout, "%s\t%d\t%d\t%s:%d\n", var[i].chr, var[i].brk1, var[i].brk2, var[i].caller,var[i].cntSameVar);
        }
    }
    return 0;
}
