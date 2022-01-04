class CertificationHissekiJob < ApplicationJob
  queue_as :default

  def perform(hisseki_path)
    reader, writer = IO.pipe

    main_pid = fork do
      reader.close

      python_library_import
      classification_model = models.load_model(Rails.root.join("ml/hisseki_classification.tf").to_s)
      certification_model = models.load_model(Rails.root.join("ml/hisseki_certification.tf").to_s)
      puts "CertificationHissekiJob: loaded models"

      target_images = read_images [hisseki_path]
      target_images = np.array(target_images)
      classification_predictions = classification_model.predict target_images
      p classification_predictions
      puts "CertificationHissekiJob: predicted user"
      certification_bool = np.amax(classification_predictions[0]) > 1.0e-1

      unless numpy_to_logical certification_bool
        puts "certification failed"
        writer.write "nil"
        exit
      end


      comparison_user = User.find(np.argmax(classification_predictions[0]))
      comparison_user_hissekis = comparison_user.hissekis
      comparison_user_images = comparison_user_hissekis.map { |hisseki| hisseki.image.current_path }
      comparison_images = read_images [comparison_user_images[rand(comparison_user_images.length)]]
      comparison_images = np.array(comparison_images, dtype: :float32)
      certification_data = [comparison_images, target_images]

      certification_predictions = certification_model.predict(
        certification_data
      )
      puts "CertificationHissekiJob: check whether is the person"
      puts certification_data

      return_value = if np.argmax(certification_predictions[0]) == 1
        comparison_user.id.to_s
      else
        "nil"
      end

      puts "certification finished successfully"
      writer.write return_value
      exit
    end

    writer.close

    Process.waitpid main_pid

    user_id = eval reader.read
    return User.find(user_id) if user_id
    user_id
  end

  private

  def numpy_to_logical(boolean)
    boolean.to_s == "True"
  end
end
