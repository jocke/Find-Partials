#!/usr/local/bin/ruby

# A very simple script that scans through one rails view file looking for 'render partials' and
# recursively prints out how they are related.
# 
# Usage:
#   ./find_partials.rb app/views/<controller>/<action>.rhtml
# 
# Limitations
#   - Only does extensions "rhtml" and "html.erb"
#   - Is not clever enough to figure out partials with "/" in the file names (shared partials)
#   - Probably won't work under Windows.
# 
# Suggested improvements:
#   - Make it work with "/" in the file names
#   - More extensions
#   - Better OO (PartialFile object?)
#   - Better output, graphical output.
#   - Smarter error handling.
#   - Detection of recursive partials
#   - Complete redesign; Scan all partials and map their relationships. Would be good for systems with a lot of shared partials.
# 
# License: DWYWWIBDBM
#   Do what you want with it but don't blame me.
# 
# Author: Jocke Selin <jocke@selincite.com>
# Version: 0.1
# Date: 2010-01-22

class FindPartials
  
  MAX_DEPTH = 10 # How deep the scanning should be - cheap and dirty fix to prevent recursive partials from causing you to die from old age.
  
  def initialize(file_name)
    @file_name  = file_name
    @dir_name   = File.dirname(@file_name)
    
    puts "\nFile Name: #{@file_name}, Dir Name: #{@dir_name}"
    if File::exists?(@file_name)
      run
    end
  end
  
  
  # Starts the process and scans the start file and then passes on to recursive scanning.
  def run
    file_content      = read_file_to_string(@file_name)
    partials_in_file  = scan_file_content(file_content)
    output_line
    puts "#{@file_name}"
    scan_files(partials_in_file, 1)
    output_line
  end
  
  
  # Scans a set of files for 'render partials'.
  def scan_files(files, depth)
    files.each do |file_name|
      puts "#{indent(depth)} #{file_name}"
      file_content = read_file_to_string(file_name)
      partials_in_file = scan_file_content(file_content)
      if depth < MAX_DEPTH
        scan_files(partials_in_file, (depth + 1))
      end
    end
  end
  
  
  # Scans a string for 'render partials', line by line.
  def scan_file_content(file_content)
    # puts "Scanning file content..."
    files = []
    re = /^.*\s*\<\%[=-]?\s*render\s+\:partial\s*\=\>\s*["']([^"']+)["'](.+)$/
    
    file_content.split("\n").each do |line|
      md = re.match(line)
      unless md.nil?
        # puts "Matched: #{md[1]}"
        files << convert_match_to_filename(md[1])
      end
    end
    files
  end
  
  
  # Builds the file name from the word in the ERB partial code. Checks for two different extensions (should add RJS etc.)
  def convert_match_to_filename(match_string)
    file_name = "#{@dir_name}/_#{match_string}."
    extension = ['rhtml', 'html.erb'].detect { |ext| File.exists?("#{file_name}#{ext}") }
    file_name += extension
    # puts "Complete File Name: #{file_name}"
    file_name
  end
  
  
  # Reads a file's content and returns one single string. 
  def read_file_to_string(file_name)
    file_content = ""
    File.open(file_name) do |file|
      while line = file.gets
        file_content += line
      end
    end
    file_content
  end
  
  
  # No comment, despite this being a comment.
  def output_line
    puts "============================================="
  end
  
  
  # Just indents the ASCII. I'm sure it could be done in a better Ruby way.
  def indent(depth)
    indent = "#{depth}:"
    depth.times do 
      indent += " ."
    end
    indent
  end
end

if ARGV[0].nil?
  puts "\n  Usage: #{File::basename(__FILE__)}  <start_file>"
  puts "  where <start_file> is the file that you want to start parsing from.\n\n"
else
  fp = FindPartials.new(ARGV[0])
end