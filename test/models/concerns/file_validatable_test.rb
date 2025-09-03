# frozen_string_literal: true

require 'test_helper'

class FileValidatableTest < ActiveSupport::TestCase
  # Create a test model that includes the concern
  class TestModel < ApplicationRecord
    self.table_name = 'users' # Use existing table for testing
    include FileValidatable
    
    has_one_attached :test_image
    has_many_attached :test_images
    has_one_attached :test_document
    has_one_attached :test_gpx
    
    validates_image_attachment :test_image
    validates_multiple_image_attachments :test_images, max_files: 3
    validates_document_attachment :test_document
    validates_gpx_attachment :test_gpx
  end

  setup do
    @model = TestModel.new(
      email: 'test@example.com',
      password: 'password123',
      nom: 'Test',
      cognoms: 'User',
      data_naixement: 25.years.ago,
      mobil: '123456789',
      moto_marca: 'Honda',
      moto_model: 'CBR',
      presentacio: 'Test'
    )
  end

  # Image validation tests
  test 'should accept valid image types' do
    valid_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
    
    valid_types.each do |content_type|
      @model.test_image.attach(
        io: StringIO.new('fake image data'),
        filename: "test.#{content_type.split('/').last}",
        content_type: content_type
      )
      
      assert @model.valid?, "Should accept #{content_type}"
      @model.test_image.purge
    end
  end

  test 'should reject invalid image content types' do
    invalid_types = %w[application/pdf text/plain video/mp4 audio/mp3]
    
    invalid_types.each do |content_type|
      @model.test_image.attach(
        io: StringIO.new('fake file data'),
        filename: "test.#{content_type.split('/').last}",
        content_type: content_type
      )
      
      assert_not @model.valid?, "Should reject #{content_type}"
      assert_includes @model.errors[:test_image], 'ha de ser una imatge vàlida'
      @model.test_image.purge
      @model.errors.clear
    end
  end

  test 'should reject invalid image extensions' do
    invalid_extensions = %w[.pdf .txt .exe .bat .php]
    
    invalid_extensions.each do |extension|
      @model.test_image.attach(
        io: StringIO.new('fake image data'),
        filename: "test#{extension}",
        content_type: 'image/jpeg'
      )
      
      assert_not @model.valid?, "Should reject #{extension}"
      assert_includes @model.errors[:test_image], 'ha de tenir una extensió vàlida'
      @model.test_image.purge
      @model.errors.clear
    end
  end

  test 'should reject oversized images' do
    large_file = StringIO.new('x' * 6.megabytes)
    @model.test_image.attach(
      io: large_file,
      filename: 'large.jpg',
      content_type: 'image/jpeg'
    )
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_image], 'és massa gran'
  end

  test 'should detect executable signatures' do
    executable_signatures = [
      "\x4D\x5A", # PE executable
      "\x7F\x45\x4C\x46", # ELF executable
      "\xCA\xFE\xBA\xBE", # Mach-O executable
      "\x50\x4B\x03\x04" # ZIP
    ]
    
    executable_signatures.each do |signature|
      malicious_content = StringIO.new(signature + 'fake executable data')
      @model.test_image.attach(
        io: malicious_content,
        filename: 'image.jpg',
        content_type: 'image/jpeg'
      )
      
      assert_not @model.valid?, "Should detect #{signature.inspect} signature"
      assert_includes @model.errors[:test_image], 'conté contingut potencialment perillós'
      @model.test_image.purge
      @model.errors.clear
    end
  end

  test 'should detect script content in images' do
    script_patterns = [
      '<script>alert("xss")</script>',
      'javascript:alert("xss")',
      'onload="alert(1)"',
      '<iframe src="evil.com"></iframe>'
    ]
    
    script_patterns.each do |script|
      malicious_content = StringIO.new("fake image header\n#{script}\nmore image data")
      @model.test_image.attach(
        io: malicious_content,
        filename: 'image.jpg',
        content_type: 'image/jpeg'
      )
      
      assert_not @model.valid?, "Should detect script: #{script}"
      assert_includes @model.errors[:test_image], 'conté contingut de script no permès'
      @model.test_image.purge
      @model.errors.clear
    end
  end

  # Multiple images validation tests
  test 'should accept multiple valid images' do
    2.times do |i|
      @model.test_images.attach(
        io: StringIO.new('fake image data'),
        filename: "image#{i}.jpg",
        content_type: 'image/jpeg'
      )
    end
    
    assert @model.valid?
  end

  test 'should reject too many images' do
    4.times do |i|
      @model.test_images.attach(
        io: StringIO.new('fake image data'),
        filename: "image#{i}.jpg",
        content_type: 'image/jpeg'
      )
    end
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_images], 'massa fitxers'
  end

  test 'should validate each image in multiple attachments' do
    # Add one valid image
    @model.test_images.attach(
      io: StringIO.new('fake image data'),
      filename: 'valid.jpg',
      content_type: 'image/jpeg'
    )
    
    # Add one invalid image
    @model.test_images.attach(
      io: StringIO.new('fake file data'),
      filename: 'invalid.pdf',
      content_type: 'application/pdf'
    )
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_images], 'fitxer 2 ha de ser una imatge vàlida'
  end

  # Document validation tests
  test 'should accept valid document types' do
    valid_types = %w[application/pdf text/plain application/msword]
    
    valid_types.each do |content_type|
      extension = case content_type
                  when 'application/pdf' then '.pdf'
                  when 'text/plain' then '.txt'
                  when 'application/msword' then '.doc'
                  end
      
      @model.test_document.attach(
        io: StringIO.new('fake document data'),
        filename: "document#{extension}",
        content_type: content_type
      )
      
      assert @model.valid?, "Should accept #{content_type}"
      @model.test_document.purge
    end
  end

  test 'should reject invalid document types' do
    @model.test_document.attach(
      io: StringIO.new('fake image data'),
      filename: 'document.jpg',
      content_type: 'image/jpeg'
    )
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_document], 'ha de ser un document vàlid'
  end

  # GPX validation tests
  test 'should accept valid GPX file' do
    gpx_content = <<~GPX
      <?xml version="1.0" encoding="UTF-8"?>
      <gpx version="1.1" creator="test">
        <trk>
          <name>Test Route</name>
        </trk>
      </gpx>
    GPX
    
    @model.test_gpx.attach(
      io: StringIO.new(gpx_content),
      filename: 'route.gpx',
      content_type: 'application/gpx+xml'
    )
    
    assert @model.valid?
  end

  test 'should accept XML file as GPX' do
    xml_content = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <gpx version="1.1">
        <trk><name>Test</name></trk>
      </gpx>
    XML
    
    @model.test_gpx.attach(
      io: StringIO.new(xml_content),
      filename: 'route.xml',
      content_type: 'text/xml'
    )
    
    assert @model.valid?
  end

  test 'should reject invalid GPX content type' do
    @model.test_gpx.attach(
      io: StringIO.new('fake gpx data'),
      filename: 'route.txt',
      content_type: 'text/plain'
    )
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_gpx], 'ha de ser un fitxer GPX vàlid'
  end

  test 'should reject GPX without proper content' do
    @model.test_gpx.attach(
      io: StringIO.new('not gpx content'),
      filename: 'route.gpx',
      content_type: 'application/gpx+xml'
    )
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_gpx], 'no conté contingut GPX vàlid'
  end

  # Edge cases and error handling
  test 'should handle file read errors gracefully' do
    # Mock file that raises an error when read
    mock_file = Minitest::Mock.new
    mock_file.expect(:read, nil) { raise StandardError, 'File read error' }
    
    @model.test_image.attach(
      io: StringIO.new('fake image data'),
      filename: 'error.jpg',
      content_type: 'image/jpeg'
    )
    
    # Mock the file opening to return our mock
    @model.test_image.stub(:open, mock_file) do
      assert_not @model.valid?
      assert_includes @model.errors[:test_image], 'no es pot validar el fitxer'
    end
  end

  test 'should handle missing attachments' do
    # Test without any attachments
    assert @model.valid? # Should be valid if attachments are not required
  end

  test 'should validate file extensions case insensitively' do
    @model.test_image.attach(
      io: StringIO.new('fake image data'),
      filename: 'image.JPG', # Uppercase extension
      content_type: 'image/jpeg'
    )
    
    assert @model.valid?
  end

  test 'should handle files without extensions' do
    @model.test_image.attach(
      io: StringIO.new('fake image data'),
      filename: 'image_without_extension',
      content_type: 'image/jpeg'
    )
    
    assert_not @model.valid?
    assert_includes @model.errors[:test_image], 'ha de tenir una extensió vàlida'
  end

  # Constants validation
  test 'should have proper constants defined' do
    assert_kind_of Array, FileValidatable::ALLOWED_IMAGE_TYPES
    assert_kind_of Array, FileValidatable::ALLOWED_DOCUMENT_TYPES
    assert_kind_of Array, FileValidatable::ALLOWED_GPX_TYPES
    assert_kind_of Array, FileValidatable::ALLOWED_IMAGE_EXTENSIONS
    
    assert FileValidatable::MAX_IMAGE_SIZE > 0
    assert FileValidatable::MAX_DOCUMENT_SIZE > 0
    assert FileValidatable::MAX_GPX_SIZE > 0
  end
end
