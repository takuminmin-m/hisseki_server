class CertificationHissekiJob < ApplicationJob
  queue_as :default

  def perform(hisseki_path)
    reader, writer = IO.pipe

    main_pid = fork do
      reader.close

      python_library_import
      user_classification_model = models.load_model("ml/hisseki_classification.tf")
      # user_certification_model = models.load_model("ml/hisseki_certification.tf")
      puts "CertificationHissekiJob: loaded models"

      target_images = read_images [hisseki_path]
      target_images = np.array target_images
      classification_predictions = user_classification_model.predict target_images
      p classification_predictions
      puts "CertificationHissekiJob: predicted user"
      certification_bool = np.amin(classification_predictions[0]) < 1.0e-5

      if numpy_to_logical certification_bool
        p "do true"
        return_value = "#{np.argmax(classification_predictions[0]) + 1}"
      else
        return_value = "nil"
      end

      # target_user = User.find(np.argmax(classification_predictions[0]) + 1)
      # target_user_hissekis = target_user.hissekis
      # target_user_images = target_user_hissekis.map { |hisseki| hisseki.image.current_path }
      # comparison_images = read_images [target_user_images[rand(target_user_images.length)]]
      # comparison_images = np.array comparison_images
      #
      # certification_predictions = user_certification_model.predict(
      #   *{comparison_image: comparison_images, target_image: target_images}
      # )
      # puts "CertificationHissekiJob: check whether is the person"
      #
      # return_value = if np.argmax(certification_predictions[0]) == 1
      #   "#{target_user.id}"
      # else
      #   "nil"
      # end

      writer.write return_value
    end

    writer.close

    Process.waitpid main_pid

    user_id = eval reader.read
    return User.find(user_id) if user_id
    user_id
  end

  private

  # pythonライブラリのインポート
  def python_library_import
    pyimport :tensorflow, as: :tf
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np
    puts "PyCall info: imported python libraries"
  end

  def numpy_to_logical(boolean)
    boolean.to_s == "True"
  end
end
