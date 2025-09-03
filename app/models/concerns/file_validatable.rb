# frozen_string_literal: true

module FileValidatable
  extend ActiveSupport::Concern

  # Allowed MIME types for different file categories
  ALLOWED_IMAGE_TYPES = %w[
    image/jpeg
    image/jpg
    image/png
    image/gif
    image/webp
  ].freeze

  ALLOWED_DOCUMENT_TYPES = %w[
    application/pdf
    text/plain
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  ALLOWED_GPX_TYPES = %w[
    application/gpx+xml
    text/xml
    application/xml
  ].freeze

  # File extensions for additional validation
  ALLOWED_IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp].freeze
  ALLOWED_DOCUMENT_EXTENSIONS = %w[.pdf .txt .doc .docx].freeze
  ALLOWED_GPX_EXTENSIONS = %w[.gpx .xml].freeze

  # Maximum file sizes
  MAX_IMAGE_SIZE = 5.megabytes
  MAX_DOCUMENT_SIZE = 10.megabytes
  MAX_GPX_SIZE = 2.megabytes

  # Image dimension limits
  MAX_IMAGE_WIDTH = 4000
  MAX_IMAGE_HEIGHT = 4000
  MIN_IMAGE_WIDTH = 50
  MIN_IMAGE_HEIGHT = 50

  class_methods do
    def validates_multiple_image_attachments(attachment_name, options = {})
      max_files = options[:max_files] || 5

      validate :"validate_#{attachment_name}_count"
      validate :"validate_#{attachment_name}_multiple_content_types"
      validate :"validate_#{attachment_name}_multiple_file_sizes"
      validate :"validate_#{attachment_name}_multiple_extensions"
      validate :"validate_#{attachment_name}_multiple_malicious_content"

      define_method :"validate_#{attachment_name}_count" do
        attachments = send(attachment_name)
        if attachments.count > max_files
          errors.add(attachment_name, :too_many_files,
                    message: "massa fitxers. Màxim permès: #{max_files}")
        end
      end

      define_method :"validate_#{attachment_name}_multiple_content_types" do
        attachments = send(attachment_name)
        attachments.each_with_index do |attachment, index|
          unless ALLOWED_IMAGE_TYPES.include?(attachment.content_type)
            errors.add(attachment_name, :invalid_content_type,
                      message: "fitxer #{index + 1} ha de ser una imatge vàlida (#{ALLOWED_IMAGE_TYPES.join(', ')})")
          end
        end
      end

      define_method :"validate_#{attachment_name}_multiple_file_sizes" do
        attachments = send(attachment_name)
        max_size = options[:max_size] || MAX_IMAGE_SIZE

        attachments.each_with_index do |attachment, index|
          if attachment.byte_size > max_size
            errors.add(attachment_name, :file_too_large,
                      message: "fitxer #{index + 1} és massa gran. Màxim: #{max_size / 1.megabyte}MB")
          end
        end
      end

      define_method :"validate_#{attachment_name}_multiple_extensions" do
        attachments = send(attachment_name)
        attachments.each_with_index do |attachment, index|
          filename = attachment.filename.to_s.downcase
          extension = File.extname(filename)

          unless ALLOWED_IMAGE_EXTENSIONS.include?(extension)
            errors.add(attachment_name, :invalid_extension,
                      message: "fitxer #{index + 1} ha de tenir una extensió vàlida (#{ALLOWED_IMAGE_EXTENSIONS.join(', ')})")
          end
        end
      end

      define_method :"validate_#{attachment_name}_multiple_malicious_content" do
        attachments = send(attachment_name)
        attachments.each_with_index do |attachment, index|
          begin
            attachment.open do |file|
              first_bytes = file.read(20)

              if contains_executable_signature?(first_bytes)
                errors.add(attachment_name, :malicious_content,
                          message: "fitxer #{index + 1} conté contingut potencialment perillós")
              end

              if attachment.content_type.start_with?('image/')
                file.rewind
                content = file.read(1024)
                if contains_script_content?(content)
                  errors.add(attachment_name, :malicious_content,
                            message: "fitxer #{index + 1} conté contingut de script no permès")
                end
              end
            end
          rescue StandardError => e
            Rails.logger.error "Error validating file #{index + 1} content: #{e.message}"
            errors.add(attachment_name, :validation_error,
                      message: "no es pot validar el fitxer #{index + 1}")
          end
        end
      end
    end

    def validates_image_attachment(attachment_name, options = {})
      validate :"validate_#{attachment_name}_presence" if options[:required]
      validate :"validate_#{attachment_name}_content_type"
      validate :"validate_#{attachment_name}_file_size"
      validate :"validate_#{attachment_name}_file_extension"
      validate :"validate_#{attachment_name}_image_dimensions", if: -> { send(attachment_name).attached? }
      validate :"validate_#{attachment_name}_malicious_content"

      define_method :"validate_#{attachment_name}_presence" do
        unless send(attachment_name).attached?
          errors.add(attachment_name, :blank, message: "ha de ser present")
        end
      end

      define_method :"validate_#{attachment_name}_content_type" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        unless ALLOWED_IMAGE_TYPES.include?(attachment.content_type)
          errors.add(attachment_name, :invalid_content_type, 
                    message: "ha de ser una imatge vàlida (#{ALLOWED_IMAGE_TYPES.join(', ')})")
        end
      end

      define_method :"validate_#{attachment_name}_file_size" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        max_size = options[:max_size] || MAX_IMAGE_SIZE
        
        if attachment.byte_size > max_size
          errors.add(attachment_name, :file_too_large,
                    message: "és massa gran. La mida màxima és #{max_size / 1.megabyte}MB")
        end
      end

      define_method :"validate_#{attachment_name}_file_extension" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        filename = attachment.filename.to_s.downcase
        extension = File.extname(filename)
        
        unless ALLOWED_IMAGE_EXTENSIONS.include?(extension)
          errors.add(attachment_name, :invalid_extension,
                    message: "ha de tenir una extensió vàlida (#{ALLOWED_IMAGE_EXTENSIONS.join(', ')})")
        end
      end

      define_method :"validate_#{attachment_name}_image_dimensions" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        return unless attachment.content_type.start_with?('image/')

        begin
          # Use ImageProcessing to get dimensions
          image = ImageProcessing::MiniMagick.source(attachment)
          metadata = image.call.identify
          width = metadata[:width]
          height = metadata[:height]

          if width && height
            if width > MAX_IMAGE_WIDTH || height > MAX_IMAGE_HEIGHT
              errors.add(attachment_name, :dimensions_too_large,
                        message: "dimensions són massa grans. Màxim: #{MAX_IMAGE_WIDTH}x#{MAX_IMAGE_HEIGHT}px")
            end

            if width < MIN_IMAGE_WIDTH || height < MIN_IMAGE_HEIGHT
              errors.add(attachment_name, :dimensions_too_small,
                        message: "dimensions són massa petites. Mínim: #{MIN_IMAGE_WIDTH}x#{MIN_IMAGE_HEIGHT}px")
            end
          end
        rescue StandardError => e
          Rails.logger.error "Error validating image dimensions: #{e.message}"
          errors.add(attachment_name, :invalid_image, message: "no és una imatge vàlida")
        end
      end

      define_method :"validate_#{attachment_name}_malicious_content" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        
        # Check for suspicious file signatures
        begin
          attachment.open do |file|
            first_bytes = file.read(20)
            
            # Check for executable signatures
            if contains_executable_signature?(first_bytes)
              errors.add(attachment_name, :malicious_content,
                        message: "conté contingut potencialment perillós")
            end
            
            # Check for script content in images
            if attachment.content_type.start_with?('image/')
              file.rewind
              content = file.read(1024) # Read first 1KB
              if contains_script_content?(content)
                errors.add(attachment_name, :malicious_content,
                          message: "conté contingut de script no permès")
              end
            end
          end
        rescue StandardError => e
          Rails.logger.error "Error validating file content: #{e.message}"
          errors.add(attachment_name, :validation_error, message: "no es pot validar el fitxer")
        end
      end
    end

    def validates_document_attachment(attachment_name, options = {})
      validate :"validate_#{attachment_name}_document_presence" if options[:required]
      
      validate :"validate_#{attachment_name}_document_content_type"
      validate :"validate_#{attachment_name}_document_file_size"
      validate :"validate_#{attachment_name}_document_file_extension"

      define_method :"validate_#{attachment_name}_document_presence" do
        unless send(attachment_name).attached?
          errors.add(attachment_name, :blank, message: "ha de ser present")
        end
      end

      define_method :"validate_#{attachment_name}_document_content_type" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        unless ALLOWED_DOCUMENT_TYPES.include?(attachment.content_type)
          errors.add(attachment_name, :invalid_content_type,
                    message: "ha de ser un document vàlid (#{ALLOWED_DOCUMENT_TYPES.join(', ')})")
        end
      end

      define_method :"validate_#{attachment_name}_document_file_size" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        max_size = options[:max_size] || MAX_DOCUMENT_SIZE
        
        if attachment.byte_size > max_size
          errors.add(attachment_name, :file_too_large,
                    message: "és massa gran. La mida màxima és #{max_size / 1.megabyte}MB")
        end
      end

      define_method :"validate_#{attachment_name}_document_file_extension" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        filename = attachment.filename.to_s.downcase
        extension = File.extname(filename)
        
        unless ALLOWED_DOCUMENT_EXTENSIONS.include?(extension)
          errors.add(attachment_name, :invalid_extension,
                    message: "ha de tenir una extensió vàlida (#{ALLOWED_DOCUMENT_EXTENSIONS.join(', ')})")
        end
      end
    end

    def validates_gpx_attachment(attachment_name, options = {})
      validate :"validate_#{attachment_name}_gpx_presence" if options[:required]
      
      validate :"validate_#{attachment_name}_gpx_content_type"
      validate :"validate_#{attachment_name}_gpx_file_size"
      validate :"validate_#{attachment_name}_gpx_file_extension"
      validate :"validate_#{attachment_name}_gpx_content"

      define_method :"validate_#{attachment_name}_gpx_presence" do
        unless send(attachment_name).attached?
          errors.add(attachment_name, :blank, message: "ha de ser present")
        end
      end

      define_method :"validate_#{attachment_name}_gpx_content_type" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        unless ALLOWED_GPX_TYPES.include?(attachment.content_type)
          errors.add(attachment_name, :invalid_content_type,
                    message: "ha de ser un fitxer GPX vàlid")
        end
      end

      define_method :"validate_#{attachment_name}_gpx_file_size" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        max_size = options[:max_size] || MAX_GPX_SIZE
        
        if attachment.byte_size > max_size
          errors.add(attachment_name, :file_too_large,
                    message: "és massa gran. La mida màxima és #{max_size / 1.megabyte}MB")
        end
      end

      define_method :"validate_#{attachment_name}_gpx_file_extension" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        filename = attachment.filename.to_s.downcase
        extension = File.extname(filename)
        
        unless ALLOWED_GPX_EXTENSIONS.include?(extension)
          errors.add(attachment_name, :invalid_extension,
                    message: "ha de tenir una extensió GPX vàlida (.gpx, .xml)")
        end
      end

      define_method :"validate_#{attachment_name}_gpx_content" do
        return unless send(attachment_name).attached?

        attachment = send(attachment_name)
        
        begin
          attachment.open do |file|
            content = file.read(1024) # Read first 1KB
            unless content.include?('<gpx') || content.include?('<?xml')
              errors.add(attachment_name, :invalid_gpx_content,
                        message: "no conté contingut GPX vàlid")
            end
          end
        rescue StandardError => e
          Rails.logger.error "Error validating GPX content: #{e.message}"
          errors.add(attachment_name, :validation_error, message: "no es pot validar el fitxer GPX")
        end
      end
    end
  end

  private

  def contains_executable_signature?(bytes)
    return false unless bytes

    # Common executable signatures
    executable_signatures = [
      "\x4D\x5A", # PE executable (Windows)
      "\x7F\x45\x4C\x46", # ELF executable (Linux)
      "\xCA\xFE\xBA\xBE", # Mach-O executable (macOS)
      "\xFE\xED\xFA\xCE", # Mach-O executable (macOS)
      "\x50\x4B\x03\x04", # ZIP (could contain executables)
    ]

    executable_signatures.any? { |sig| bytes.start_with?(sig) }
  end

  def contains_script_content?(content)
    return false unless content

    # Look for script tags and suspicious content
    script_patterns = [
      /<script/i,
      /javascript:/i,
      /vbscript:/i,
      /onload=/i,
      /onerror=/i,
      /onclick=/i,
      /<iframe/i,
      /<object/i,
      /<embed/i
    ]

    script_patterns.any? { |pattern| content.match?(pattern) }
  end
end
