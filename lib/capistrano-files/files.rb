
def tmp_path(file)
  "tmp/#{string_timestamp}_#{File.basename(file)}"
end

def string_timestamp
  Time.now.strftime('%Y%m%dT%H%M%S')
end

def remote_path(file)
  File.join(shared_path, file)
end

def prompt(msg, prompt = "(y)es, (n)o ")
  ask(:answer, "#{msg} #{prompt} ? ")
  (fetch(:answer) =~ /^y$|^yes$/i) == 0
end

def diff_files(file1, file2)
  `git diff --no-index --color=always --ignore-space-at-eol #{file1} #{file2}`
end

namespace :files do

  task :symlink do
    on roles(:app) do
      symlinks = fetch(:file_symlinks)

      symlinks.each do |symlink|
        sudo "ln -f #{shared_path}/#{symlink[:source]} #{symlink[:link]}"
      end
    end
  end

  after 'deploy:symlink:release', 'files:symlink'

  task :upload do
    on roles(:app) do
      files = fetch(:file_uploads)

      files.each do |file_metadata|
        destination_file = file_metadata[:destination]
        origin_file = file_metadata[:origin]

        tmp_path = tmp_path(destination_file)
        download!(remote_path(destination_file), tmp_path)

        diff_result = diff_files(tmp_path, origin_file)

        if !diff_result.empty? && prompt("#{diff_result} \nUpdate ?")
          upload!(origin_file, remote_path(destination_file))
        end
      end
    end
  end
end

