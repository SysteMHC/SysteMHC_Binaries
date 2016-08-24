#!/usr/bin/python

from __future__ import print_function
from bs4 import BeautifulSoup
import csv
import gflags
import sys

gflags.DEFINE_string("input_file", None, "Input file")
gflags.DEFINE_string("output_file", None, "Output file")

FLAGS = gflags.FLAGS


def main(argv):
    """
    Convert the output of Lib2HTML to csv format.

    Usage:
      spectrast_html_lib_2_csv.py --input_file=<file> --output_file=<file>

      --input_file:       input file (the HTML converted library)
      --output_file:      output file (the resulting csv table)

    Returns:
      A csv file with the spectral library information.
      LibID is substituted with corresponding plotspectrast.cgi link
    """

    FLAGS(argv)

    ## Read HTML file
    with open(FLAGS.input_file, 'r') as fin:
        soup = BeautifulSoup(fin, 'html.parser')

    ## Parse it and write the table as a tsv
    with open(FLAGS.output_file, 'wb') as fout:
        csv_out = csv.writer(fout, delimiter='\t')
        for row in soup.find_all('tr'):
            cols = row.find_all(['th', 'td'])
            cols = ['<a href=\'' + col.a['href'] + '\'>' + col.text + '</a>' if col.a else col.text for col in cols]
            csv_out.writerow(cols)


if __name__ == "__main__":
    gflags.MarkFlagsAsRequired(["input_file", "output_file"])
    main(sys.argv)
