#!/usr/bin/env  rvm default do ruby
require 'rubygems'
require 'csv'
require 'spreadsheet'

class Datafile
    def initialize(basefile)
        @basefile = basefile
    end

    attr_accessor :testfile
    attr_reader :basefile

    def createTestfile

    end

    def addColumns(n)
        for i in 1..n
            table = CSV.read(testfile, {headers: true, col_sep: ","})
            # add a new column to the CSV
            header = "Additional Column " + i.to_s
            table.each do |row|
                row[header] = rand(10000)
            end
        end
    end

    def addRows(file)
        to_append = File.read(file)
        File.open(testfile, "a") do |handle|
            handle.puts to_append
        end
    end

    def convertXLSX

    end

    def convertXLS(path)
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet

        header_format = Spreadsheet::Format.new()

        sheet1.row(0).default_format = header_format

        CSV.open(testfile, 'r') do |c|
          c.each_with_index do |row, i|
            sheet1.row(i).replace(row)
          end
        end
        book.write(path)
    end

    def saveCSV
    end
end