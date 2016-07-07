require 'optparse'
require 'backlog_kit'
require 'uri'

module Backlogcp
  class CLI
    def run
      opts, args = parse_options
      dl(args[0], args[1])
    end

    private

    def dl(from, to)
      if %r(^https://(?<space_id>.+)\.backlog.jp/file/) =~ URI.unescape(from)
        dl_from_shared_file(from, to)
      else
        dl_from_issue_attachment(from, to)
      end
    end

    # https://[space_id].backlog.jp/file/[project_key]/[dir][filename]
    def dl_from_shared_file(from, to)
      unless %r(^https://(?<space_id>.+)\.backlog.jp/file/(?<project_key>[^/]+)(?<dir>/?.*/)(?<filename>[^/]+)$) =~ URI.unescape(from)
        usage '<from> option should be backlog.jp URI.'
      end
      local = File.expand_path(to)
      to_file_path = if File.directory?(local)
                       local + '/' + filename
                     else
                       local
                     end
      client = BacklogKit::Client.new(space_id: space_id)
      files = client.get_shared_files(project_key, dir).body
      selected = files.find do |res|
        res.name == filename
      end
      puts to_file_path
      res = client.download_shared_file(project_key, selected.id)
      File.binwrite(to_file_path, res.body.content)
    end

    # https://[space_id].backlog.jp/ViewAttachment.action?attachmentId=[attachment_id]
    def dl_from_issue_attachment(from, to)
      if %r(^https://(?<space_id>.+)\.backlog.jp/.+attachmentId=(?<attachment_id>[^/]+)$) =~ URI.unescape(from)
      elsif %r(^https://(?<space_id>.+)\.backlog.jp/downloadAttachment/(?<attachment_id>[^/]+)) =~ URI.unescape(from)
      else
        usage '<from> option should be backlog.jp URI.'
      end

      selected, attachment = get_issue_and_attachment(space_id, attachment_id)

      filename = attachment.name
      local = File.expand_path(to)
      to_file_path = if File.directory?(local)
                       local + '/' + filename
                     else
                       local
                     end
      puts to_file_path
      client = BacklogKit::Client.new(space_id: space_id)
      res = client.download_issue_attachment(selected.issueKey, attachment.id)
      File.binwrite(to_file_path, res.body.content)
    end

    # http://qiita.com/sonots/items/1b44ed3a770ef790a63d
    def parse_options(argv = ARGV)
      op = OptionParser.new

      self.class.module_eval do
        define_method(:usage) do |msg = nil|
          puts op.to_s
          puts "error: #{msg}" if msg
          exit 1
        end
      end

      opts = {}

      op.banner += ' <from:Backlog shared file URI> <to>'

      begin
        args = op.parse(argv)
      rescue OptionParser::InvalidOption => e
        usage e.message
      end

      usage 'number of arguments is less than 2' if args.size < 2

      [opts, args]
    end

    def get_issue_and_attachment(space_id, attachment_id)
      client = BacklogKit::Client.new(space_id: space_id)

      selected = nil
      attachment = nil
      limit = 100
      offset = 0
      loop do
        issues = client.get_issues({
                                     attachment: true,
                                     count: limit,
                                     offset: offset * limit
                                   }).body
        issues.each do |issue|
          issue.attachments.each do |a|
            if a.id.to_s == attachment_id
              attachment = a
              selected = issue
            end
          end
        end

        (!selected && issues.length == limit) || break
        offset += 1
      end
      usage 'file not found' unless selected

      [selected, attachment]
    end
  end
end
