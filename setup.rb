#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require 'google-refine'
require 'csv'
require 'faker'

opts = {}
opts["file_name"] = "test.csv"
opts["project_name"] = "timer"
ops = File.read('operations.json')
filename = "test.csv"

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

fd = FakeData.new('test.csv',25000)


CSV.open('timings.csv', 'w', :write_headers=> true, :headers => ["lines","load","operations","export"]) do |writer|
    while true
        line_count = `wc -l "#{filename}"`.strip.split(' ')[0].to_i-1
        load_total = 0
        operations_total = 0
        export_total = 0
        reps = 3
            for k in 1..reps
                begin
                    start = Time.now
                    prj = Refine.new(opts)
                    finish = Time.now
                    load_total += finish - start
                rescue
                    "Failed to load " + line_count + " lines"
                    exit
                end

                begin
                    start = Time.now
                    prj.apply_operations(ops)
                    finish = Time.now
                    operations_total += finish - start
                rescue
                    "Failed to do operations on " + line_count + " lines"
                    exit
                end

                begin
                    start = Time.now
                    prj.export_rows('csv')
                    finish = Time.now
                    export_total = finish - start
                rescue
                    "Failed to export " + line_count + " lines"
                    exit
                end

                begin
                    prj.delete_project
                rescue
                    "Failed to delete project at" + line_count + " lines"
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
