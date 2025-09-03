# frozen_string_literal: true

require 'test_helper'

class SortideTest < ActiveSupport::TestCase
  setup do
    @sortide = build(:sortide)
  end

  # Basic validations
  test 'should be valid with valid attributes' do
    assert @sortide.valid?
  end

  test 'should require title' do
    @sortide.title = nil
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:title], "can't be blank"
  end

  test 'should require descripcio' do
    @sortide.descripcio = nil
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:descripcio], "can't be blank"
  end

  test 'should require start_date' do
    @sortide.start_date = nil
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:start_date], "can't be blank"
  end

  test 'should require start_time' do
    @sortide.start_time = nil
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:start_time], "can't be blank"
  end

  test 'should require start_point' do
    @sortide.start_point = nil
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:start_point], "can't be blank"
  end

  test 'should require preu' do
    @sortide.preu = nil
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:preu], "can't be blank"
  end

  test 'should require non-negative preu' do
    @sortide.preu = -10
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:preu], 'must be greater than or equal to 0'
  end

  # File upload validations
  test 'should accept valid ruta_foto image' do
    @sortide.ruta_foto.attach(
      io: StringIO.new('fake image data'),
      filename: 'route.jpg',
      content_type: 'image/jpeg'
    )
    assert @sortide.valid?
  end

  test 'should reject ruta_foto with invalid content type' do
    @sortide.ruta_foto.attach(
      io: StringIO.new('fake file data'),
      filename: 'document.pdf',
      content_type: 'application/pdf'
    )
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:ruta_foto], 'ha de ser una imatge vàlida'
  end

  test 'should reject oversized ruta_foto' do
    large_file = StringIO.new('x' * 6.megabytes)
    @sortide.ruta_foto.attach(
      io: large_file,
      filename: 'large_route.jpg',
      content_type: 'image/jpeg'
    )
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:ruta_foto], 'és massa gran'
  end

  test 'should accept valid GPX file' do
    gpx_content = <<~GPX
      <?xml version="1.0" encoding="UTF-8"?>
      <gpx version="1.1" creator="test">
        <trk>
          <name>Test Route</name>
          <trkseg>
            <trkpt lat="41.3851" lon="2.1734">
              <ele>12</ele>
            </trkpt>
          </trkseg>
        </trk>
      </gpx>
    GPX

    @sortide.ruta_gpx.attach(
      io: StringIO.new(gpx_content),
      filename: 'route.gpx',
      content_type: 'application/gpx+xml'
    )
    assert @sortide.valid?
  end

  test 'should reject invalid GPX content type' do
    @sortide.ruta_gpx.attach(
      io: StringIO.new('fake gpx data'),
      filename: 'route.txt',
      content_type: 'text/plain'
    )
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:ruta_gpx], 'ha de ser un fitxer GPX vàlid'
  end

  test 'should reject GPX with invalid content' do
    @sortide.ruta_gpx.attach(
      io: StringIO.new('not gpx content'),
      filename: 'route.gpx',
      content_type: 'application/gpx+xml'
    )
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:ruta_gpx], 'no conté contingut GPX vàlid'
  end

  test 'should reject oversized GPX file' do
    large_gpx = StringIO.new('x' * 3.megabytes)
    @sortide.ruta_gpx.attach(
      io: large_gpx,
      filename: 'large_route.gpx',
      content_type: 'application/gpx+xml'
    )
    assert_not @sortide.valid?
    assert_includes @sortide.errors[:ruta_gpx], 'és massa gran'
  end

  # Association tests
  test 'should have many inscripcios' do
    assert_respond_to @sortide, :inscripcios
  end

  test 'should have many users through inscripcios' do
    assert_respond_to @sortide, :users
  end

  test 'should have many images' do
    assert_respond_to @sortide, :images
  end

  test 'should accept nested attributes for images' do
    @sortide.images_attributes = [
      {
        file: fixture_file_upload('test_image.jpg', 'image/jpeg'),
        caption: 'Test image'
      }
    ]
    assert @sortide.valid?
  end

  test 'should have many sortide_comments' do
    assert_respond_to @sortide, :sortide_comments
  end

  test 'should destroy dependent records when destroyed' do
    @sortide.save!
    
    # Create dependent records
    inscripcio = create(:inscripcio, sortide: @sortide)
    image = create(:image, sortide: @sortide)
    
    inscripcio_id = inscripcio.id
    image_id = image.id
    
    @sortide.destroy
    
    assert_nil Inscripcio.find_by(id: inscripcio_id)
    assert_nil Image.find_by(id: image_id)
  end

  # Friendly ID tests
  test 'should generate slug from title' do
    @sortide.title = 'Amazing Mountain Route'
    @sortide.save!
    
    assert_not_nil @sortide.slug
    assert_includes @sortide.slug, 'amazing-mountain-route'
  end

  test 'should handle duplicate slugs' do
    sortide1 = create(:sortide, title: 'Mountain Route')
    sortide2 = build(:sortide, title: 'Mountain Route')
    
    sortide2.save!
    
    assert_not_equal sortide1.slug, sortide2.slug
  end

  # Scope tests
  test 'should have approved scope' do
    approved_sortide = create(:sortide, approved: true)
    unapproved_sortide = create(:sortide, approved: false)
    
    approved_sortides = Sortide.approved
    
    assert_includes approved_sortides, approved_sortide
    assert_not_includes approved_sortides, unapproved_sortide
  end

  test 'should have upcoming scope' do
    future_sortide = create(:sortide, start_date: 1.week.from_now)
    past_sortide = create(:sortide, start_date: 1.week.ago)
    
    upcoming_sortides = Sortide.upcoming
    
    assert_includes upcoming_sortides, future_sortide
    assert_not_includes upcoming_sortides, past_sortide
  end

  # Business logic tests
  test 'should calculate available spots' do
    @sortide.max_inscrits = 10
    @sortide.save!
    
    # Create some inscriptions
    3.times { create(:inscripcio, sortide: @sortide) }
    
    assert_equal 7, @sortide.available_spots
  end

  test 'should check if full' do
    @sortide.max_inscrits = 2
    @sortide.save!
    
    assert_not @sortide.full?
    
    2.times { create(:inscripcio, sortide: @sortide) }
    
    assert @sortide.full?
  end

  test 'should check if user can inscribe' do
    user = create(:user)
    @sortide.save!
    
    assert @sortide.can_inscribe?(user)
    
    # Create inscription
    create(:inscripcio, user: user, sortide: @sortide)
    
    assert_not @sortide.can_inscribe?(user)
  end

  test 'should calculate total price with plan discount' do
    basic_user = create(:user, plan: create(:plan, :basic))
    premium_user = create(:user, plan: create(:plan, :premium))
    
    @sortide.preu = 100
    @sortide.save!
    
    # Assuming basic plan has no discount, premium has 20% discount
    assert_equal 100, @sortide.price_for_user(basic_user)
    assert_equal 80, @sortide.price_for_user(premium_user)
  end

  # Validation edge cases
  test 'should handle very long title' do
    @sortide.title = 'a' * 1000
    assert @sortide.valid? # Should be valid unless there's a length limit
  end

  test 'should handle special characters in title' do
    @sortide.title = 'Ruta amb àccents i caràcters especials!'
    assert @sortide.valid?
  end

  test 'should handle zero price' do
    @sortide.preu = 0
    assert @sortide.valid?
  end

  test 'should handle decimal prices' do
    @sortide.preu = 25.50
    assert @sortide.valid?
  end

  private

  def fixture_file_upload(filename, content_type)
    # Create a temporary file for testing
    file = Tempfile.new([filename, File.extname(filename)])
    file.write('fake image data')
    file.rewind
    
    ActionDispatch::Http::UploadedFile.new(
      tempfile: file,
      filename: filename,
      type: content_type
    )
  end
end
