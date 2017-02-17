#OpenRefine Timer
##Overview
This is a very basic file to test how well OpenRefine scales. It creates a csv file, loads it into OpenRefine, carries out a few basic operations, then exports the file as a tsv. Each step in this process is timed, and the timings recorded in a csv file for analysis.

The script uses the google-refine gem by Max Ogden https://github.com/maxogden/refine-ruby, and the faker gem by Benjamin Curtis https://github.com/stympy/faker.

The script will keep going until some part of the process fails.

##Running the tests
OpenRefine must already be running and available on http://127.0.0.1:3333 to successfully run the scripts.

The script runs from the command line with the following flags:
Usage: openrefine_scale_test.rb [options]
    -f, --filename [FILENAME]        Name to use for data file to be used in testing
    -p, --projectname [PROJECTNAME]  Name to use for OpenRefine project to be used for testing
    -i, --increments [INCREMENTS]    Number of lines to increment data file by each run
    -o [OPERATIONSFILE],             Valid JSON file of OpenRefine operations to carry out during testing
        --operationsfile
    -t, --timingsfile [TIMINGSFILE]  File to save the timings to
    -r, --repeats [REPEATS]          Number of times to repeat each test to get average
    -h, --help                       Show this message

You'll need to enter correct values for all flags (except -h) to successfully run the script. For example:

./openrefine_scale_test.rb -f data.csv -p timings -i 25000 -o operations.json -t timings.csv -r 1

##Caveats
This script is meant to help give a rough idea of the limits of OpenRefine, not offer definitive information about its capacity. There are many factors that may affect the performance of OpenRefine including:

* Amount of memory allocated (see https://github.com/OpenRefine/OpenRefine/wiki/FAQ:-Allocate-More-Memory)
* Number of rows in the file
* Number of columns in the file
* The format of the file from which data is loaded into OpenRefine

The script measures timings in terms of calling the relevant command via the refine-ruby gem, and waiting until it has completed - this may not reflect the time actually taken for OpenRefine to carry out the operation.

##TO DO
I'd like to:
* Enable the data file used for testing to have columns added as well as rows
* Offer conversion of the data file used for testing into other formats (e.g. xls) to test if this makes a difference to performance
* Build in graphing of the results of the test

