namespace :presenter_resume do
  desc "Regenerate db/fixtures/files/presenter_resume.pdf from seed template"
  task regenerate: :environment do
    require Rails.root.join("db/seeds/presenter_resume_pdf")

    path = Rails.root.join("db/fixtures/files/presenter_resume.pdf")
    File.binwrite(path, Seeds::PresenterResumePdf.render)
    puts "Wrote #{path} (#{File.size(path)} bytes)"
  end
end
