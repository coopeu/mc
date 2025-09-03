# frozen_string_literal: true

require 'test_helper'

class SortidesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sortide = create(:sortide)
    @user = create(:user)
    @admin = create(:user, admin: true)
  end

  # Index action tests
  test 'should get index' do
    get sortides_url
    assert_response :success
    assert_select 'h1', /sortides/i
  end

  test 'should show only approved sortides in index' do
    approved_sortide = create(:sortide, approved: true, title: 'Approved Route')
    unapproved_sortide = create(:sortide, approved: false, title: 'Unapproved Route')
    
    get sortides_url
    assert_response :success
    assert_select 'body', text: /Approved Route/
    assert_select 'body', text: /Unapproved Route/, count: 0
  end

  test 'should filter sortides by category' do
    category = create(:category, nom: 'Mountain')
    mountain_sortide = create(:sortide, category: category, title: 'Mountain Route')
    other_sortide = create(:sortide, title: 'Beach Route')
    
    get sortides_url, params: { category_id: category.id }
    assert_response :success
    assert_select 'body', text: /Mountain Route/
    assert_select 'body', text: /Beach Route/, count: 0
  end

  # Show action tests
  test 'should show sortide' do
    get sortide_url(@sortide)
    assert_response :success
    assert_select 'h1', @sortide.title
  end

  test 'should show inscription button for authenticated users' do
    sign_in @user
    get sortide_url(@sortide)
    assert_response :success
    assert_select 'form[action*="inscripcions"]'
  end

  test 'should not show inscription button for unauthenticated users' do
    get sortide_url(@sortide)
    assert_response :success
    assert_select 'form[action*="inscripcions"]', count: 0
    assert_select 'a[href*="sign_in"]'
  end

  test 'should show inscription status for enrolled users' do
    create(:inscripcio, user: @user, sortide: @sortide)
    sign_in @user
    
    get sortide_url(@sortide)
    assert_response :success
    assert_select '.inscription-status', text: /inscrit/i
  end

  # New action tests (admin only)
  test 'should get new for admin' do
    sign_in @admin
    get new_sortide_url
    assert_response :success
    assert_select 'form[action*="sortides"]'
  end

  test 'should redirect new for non-admin' do
    sign_in @user
    get new_sortide_url
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'should redirect new for unauthenticated user' do
    get new_sortide_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  # Create action tests
  test 'should create sortide for admin' do
    sign_in @admin
    
    assert_difference('Sortide.count') do
      post sortides_url, params: {
        sortide: {
          title: 'New Test Route',
          descripcio: 'A great route for testing purposes with enough description',
          start_date: 1.week.from_now,
          start_time: '09:00',
          start_point: 'Test Starting Point',
          preu: 25.0,
          max_inscrits: 10,
          min_inscrits: 3,
          Km: 50,
          num_dies: 1,
          fi_ndies: 1,
          oberta: true
        }
      }
    end
    
    assert_response :redirect
    assert_redirected_to sortide_path(Sortide.last)
    assert_equal 'New Test Route', Sortide.last.title
  end

  test 'should not create sortide with invalid data' do
    sign_in @admin
    
    assert_no_difference('Sortide.count') do
      post sortides_url, params: {
        sortide: {
          title: '', # Invalid: empty title
          descripcio: 'Short', # Invalid: too short
          start_date: nil, # Invalid: missing date
          preu: -10 # Invalid: negative price
        }
      }
    end
    
    assert_response :unprocessable_entity
    assert_select '.error', minimum: 1
  end

  test 'should handle file uploads in create' do
    sign_in @admin
    
    image_file = fixture_file_upload('test_image.jpg', 'image/jpeg')
    gpx_file = fixture_file_upload('test_route.gpx', 'application/gpx+xml')
    
    assert_difference('Sortide.count') do
      post sortides_url, params: {
        sortide: {
          title: 'Route with Files',
          descripcio: 'A route with image and GPX file attachments for testing',
          start_date: 1.week.from_now,
          start_time: '09:00',
          start_point: 'Test Point',
          preu: 25.0,
          max_inscrits: 10,
          min_inscrits: 3,
          Km: 50,
          num_dies: 1,
          fi_ndies: 1,
          oberta: true,
          ruta_foto: image_file,
          ruta_gpx: gpx_file
        }
      }
    end
    
    sortide = Sortide.last
    assert sortide.ruta_foto.attached?
    assert sortide.ruta_gpx.attached?
  end

  # Edit action tests
  test 'should get edit for admin' do
    sign_in @admin
    get edit_sortide_url(@sortide)
    assert_response :success
    assert_select 'form[action*="sortides"]'
    assert_select 'input[value=?]', @sortide.title
  end

  test 'should not get edit for non-admin' do
    sign_in @user
    get edit_sortide_url(@sortide)
    assert_response :redirect
    assert_redirected_to root_path
  end

  # Update action tests
  test 'should update sortide for admin' do
    sign_in @admin
    
    patch sortide_url(@sortide), params: {
      sortide: {
        title: 'Updated Route Title',
        preu: 30.0
      }
    }
    
    assert_response :redirect
    assert_redirected_to @sortide
    @sortide.reload
    assert_equal 'Updated Route Title', @sortide.title
    assert_equal 30.0, @sortide.preu
  end

  test 'should not update sortide with invalid data' do
    sign_in @admin
    original_title = @sortide.title
    
    patch sortide_url(@sortide), params: {
      sortide: {
        title: '', # Invalid
        preu: -5 # Invalid
      }
    }
    
    assert_response :unprocessable_entity
    @sortide.reload
    assert_equal original_title, @sortide.title
  end

  # Destroy action tests
  test 'should destroy sortide for admin' do
    sign_in @admin
    
    assert_difference('Sortide.count', -1) do
      delete sortide_url(@sortide)
    end
    
    assert_response :redirect
    assert_redirected_to sortides_url
  end

  test 'should not destroy sortide for non-admin' do
    sign_in @user
    
    assert_no_difference('Sortide.count') do
      delete sortide_url(@sortide)
    end
    
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'should not destroy sortide with inscriptions' do
    sign_in @admin
    create(:inscripcio, sortide: @sortide)
    
    assert_no_difference('Sortide.count') do
      delete sortide_url(@sortide)
    end
    
    assert_response :redirect
    assert_match /cannot be deleted/i, flash[:alert]
  end

  # Search functionality tests
  test 'should search sortides by title' do
    mountain_route = create(:sortide, title: 'Mountain Adventure', approved: true)
    beach_route = create(:sortide, title: 'Beach Ride', approved: true)
    
    get sortides_url, params: { search: 'Mountain' }
    assert_response :success
    assert_select 'body', text: /Mountain Adventure/
    assert_select 'body', text: /Beach Ride/, count: 0
  end

  test 'should search sortides by location' do
    barcelona_route = create(:sortide, start_point: 'Barcelona Center', approved: true)
    madrid_route = create(:sortide, start_point: 'Madrid Plaza', approved: true)
    
    get sortides_url, params: { search: 'Barcelona' }
    assert_response :success
    assert_select 'body', text: /Barcelona Center/
    assert_select 'body', text: /Madrid Plaza/, count: 0
  end

  # Pagination tests
  test 'should paginate sortides' do
    # Create many sortides
    25.times { |i| create(:sortide, title: "Route #{i}", approved: true) }
    
    get sortides_url
    assert_response :success
    assert_select '.pagination'
  end

  # JSON API tests
  test 'should return JSON for API requests' do
    get sortides_url, headers: { 'Accept' => 'application/json' }
    assert_response :success
    assert_equal 'application/json', response.content_type
    
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
  end

  test 'should return sortide JSON with details' do
    get sortide_url(@sortide), headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @sortide.title, json_response['title']
    assert_equal @sortide.id, json_response['id']
  end

  # Error handling tests
  test 'should handle non-existent sortide' do
    get sortide_url(id: 99999)
    assert_response :not_found
  end

  test 'should handle invalid sortide ID format' do
    get sortide_url(id: 'invalid')
    assert_response :not_found
  end

  private

  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  def fixture_file_upload(filename, content_type)
    file = Tempfile.new([filename, File.extname(filename)])
    
    if filename.include?('.gpx')
      file.write(<<~GPX)
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
    else
      file.write('fake image data')
    end
    
    file.rewind
    
    ActionDispatch::Http::UploadedFile.new(
      tempfile: file,
      filename: filename,
      type: content_type
    )
  end
end
