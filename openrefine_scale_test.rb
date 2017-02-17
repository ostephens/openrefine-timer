#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require 'google-refine'
require 'csv'
require 'faker'
require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: openrefine_scale_test.rb [options]"

    opts.on("-f", "--filename [FILENAME]","Name to use for data file to be used in testing") do |f|
        options[:filename] = f
    end

    opts.on("-p", "--projectname [PROJECTNAME]","Name to use for OpenRefine project to be used for testing") do |p|
        options[:projectname] = p
    end

    opts.on("-i", "--increments [INCREMENTS]","Number of lines to increment data file by each run") do |i|
        options[:increments] = i
    end

    opts.on("-o", "--operationsfile [OPERATIONSFILE]","Valid JSON file of OpenRefine operations to carry out during testing") do |o|
        options[:operations] = o
    end

    opts.on("-t", "--timingsfile [TIMINGSFILE]", "File to save the timings to") do |t|
        options[:timings] = t
    end

    opts.on("-r", "--repeats [REPEATS]", "Number of times to repeat each test to get average") do |r|
        options[:reps] = r
    end

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end
end.parse!

or_opts = {}
or_opts["file_name"] = options[:filename]
or_opts["project_name"] = options[:projectname]
if(options[:operations])
    ops = File.read(options[:operations])
else
    ops = false
end
reps = options[:reps].to_i

class FakeData
    def initialize(filename,increments)
        @filename = filename
        @increments = increments
        CSV.open(@filename, 'w', :write_headers => true, :headers => ["Column 1","Column 2","Column 3","Column 4"]) do |w|
            name = Faker::Name.name_with_middle
            email = Faker::Internet.email
            address = Faker::Address.street_address
            city = Faker::Address.city
            w << ([name,email,address,city])
        end
    end

    def append
        CSV.open(@filename, 'a+') do |w|
            for i in 1..@increments
                name = Faker::Name.name_with_middle
                email = Faker::Internet.email
                address = Faker::Address.street_address
                city = Faker::Address.city
                w << ([name,email,address,city])
            end
        end
    end
end

fd = FakeData.new(options[:filename],options[:increments].to_i)
filename = options[:filename]

CSV.open(options[:timings], 'w', :write_headers=> true, :headers => ["lines","load","operations","export"]) do |writer|
    while(true)
        line_count = `wc -l "#{filename}"`.strip.split(' ')[0].to_i-1
        puts "Lines in test data file: "+line_count.to_s
        load_total = 0
        operations_total = 0
        export_total = 0
        for k in 1..reps
            begin
                start = Time.now
                prj = Refine.new(or_opts)
                finish = Time.now
                load_total += finish - start
            rescue
                puts "Failed to load " + line_count.to_s + " lines"
                exit
            end
            if(ops)
                begin
                    start = Time.now
                    prj.apply_operations(ops)
                    finish = Time.now
                    operations_total += finish - start
                rescue
                    puts "Failed to do operations on " + line_count.to_s + " lines"
                    exit
                end
            else
                operations_total = 0
            end

            begin
                start = Time.now
                prj.export_rows('csv')
                finish = Time.now
                export_total = finish - start
            rescue
                puts "Failed to export " + line_count.to_s + " lines"
                exit
            end

            begin
                prj.delete_project
            rescue
                puts "Failed to delete project at" + line_count.to_s + " lines"
                exit
            end
        end
        load_avg = load_total / reps
        operations_avg = operations_total / reps
        export_avg = export_total / reps

        writer << ([line_count.to_s,load_avg.to_s,operations_avg.to_s,export_avg.to_s])
        fd.append
    end
end
