#! /usr/bin/env ruby

# == Author
#   Case Larsen
#
# == Copyright
#   Copyright (c) 2014 Case Larsen

require 'ostruct'
require 'chronic'

# $: << File.join(File.dirname(__FILE__), "/.")
$: << File.dirname(__FILE__)
require 'task_manager'

class OFReport
  VERSION = '0.1'
  BANNER = "Usage: of-report [options]"
  MORE_INFO = "For help use: of-report -h"

  attr_reader :options

  def initialize(args, stdin)
    @arguments = args
    @stdin = stdin
    @options = OpenStruct.new
  end

  def run
    usage_and_exit unless parsed_options?
    report
  end

  protected

  def parsed_options?
    true
  end

  def usage_and_exit
    puts BANNER
    puts
    puts MORE_INFO
    exit(0)
  end

  def report
    task_man = TaskManager.new
    tasks_per_project = {}
    start = Chronic.parse("Last sunday")
    start = Date.parse(start.strftime('%Y/%m/%d'))
    task_man.completed_tasks(start).each { |task|
      dt = task_man.ofdate_to_string(task.completion_date)
      proj = task.containing_project.get
      puts "#{dt} - #{proj.name.get} - #{task.name.get}"
      if not tasks_per_project.has_key?(proj)
        tasks_per_project[proj] = []
      end
      tasks_per_project[proj] << { 'completion_date' => dt, 'task' => task }

    }
    puts "----------- report of completed tasks since #{start} ---------"
    tasks_per_project.each do |project, value|
      puts "- #{project.name.get}"
      tasks_per_project[project].sort! { |a,b|
        a['completion_date'] <=> b['completion_date']
      }
      tasks_per_project[project].each do |v|
        print "    - #{v['completion_date']} - #{v['task'].name.get}\n"
      end
    end

  end
end

app = OFReport.new(ARGV, STDIN)
app.run
