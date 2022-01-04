class LearnHissekiJob < ApplicationJob
  queue_as :default

  def perform
    generate_image_csv
    system("python3 #{Rails.root.join("ml/python_script/create_model.py")} classification")
    system("python3 #{Rails.root.join("ml/python_script/create_model.py")} certification")
  end

end
