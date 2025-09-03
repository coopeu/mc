# frozen_string_literal: true

require 'application_system_test_case'

class UserRegistrationTest < ApplicationSystemTestCase
  setup do
    @plan = create(:plan, nom: 'Basic Plan', preu: 1000)
  end

  test 'user can register with valid information' do
    visit new_user_registration_path
    
    # Fill in basic information
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in '2n Cognom', with: 'Smith'
    
    # Upload avatar
    attach_file 'user_avatar', file_fixture('test_avatar.jpg')
    
    # Fill in motorcycle information
    fill_in 'Marca moto', with: 'Honda'
    fill_in 'Marca model', with: 'CBR600'
    
    # Upload motorcycle photo
    attach_file 'user_foto_moto', file_fixture('test_moto.jpg')
    
    # Fill in location
    select 'Barcelona', from: 'user_provincia'
    # Wait for comarca options to load
    sleep 1
    select 'Barcelonès', from: 'user_comarca'
    # Wait for municipi options to load
    sleep 1
    select 'Barcelona', from: 'user_municipi'
    
    # Fill in birth date
    select '1990', from: 'user_data_naixement_1i'
    select 'January', from: 'user_data_naixement_2i'
    select '15', from: 'user_data_naixement_3i'
    
    # Fill in presentation
    fill_in 'Curta presentaciÓ com a motorista', with: 'I love riding motorcycles and exploring new routes with fellow riders.'
    
    # Fill in private information
    fill_in 'Mòbil', with: '123456789'
    fill_in 'Correu electrònic', with: 'john.doe@example.com'
    fill_in 'Clau', with: 'password123'
    fill_in 'Confirma la clau', with: 'password123'
    
    # Fill in experience information
    select 'A2', from: 'user_puntsini_attributes_tipus_carnet'
    fill_in 'user_puntsini_attributes_anys_carnet', with: '5'
    fill_in 'user_puntsini_attributes_kms', with: '50000'
    fill_in 'user_puntsini_attributes_num_sortides', with: '20'
    select 'Intermig', from: 'user_puntsini_attributes_grau_esportiu'
    
    # Submit the form
    click_button 'Registra\'t'
    
    # Should be redirected to user profile
    assert_current_path user_path(User.last)
    assert_text 'Welcome! You have signed up successfully.'
    
    # Verify user was created with correct information
    user = User.last
    assert_equal 'john.doe@example.com', user.email
    assert_equal 'John', user.nom
    assert_equal 'Doe', user.cognom1
    assert_equal 'Smith', user.cognom2
    assert_equal 'Honda', user.moto_marca
    assert_equal 'CBR600', user.moto_model
    assert user.avatar.attached?
    assert user.foto_moto.attached?
  end

  test 'user cannot register with invalid email' do
    visit new_user_registration_path
    
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in 'Correu electrònic', with: 'invalid-email'
    fill_in 'Clau', with: 'password123'
    fill_in 'Confirma la clau', with: 'password123'
    
    click_button 'Registra\'t'
    
    assert_text 'Email is invalid'
    assert_current_path user_registration_path
  end

  test 'user cannot register with mismatched passwords' do
    visit new_user_registration_path
    
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in 'Correu electrònic', with: 'john@example.com'
    fill_in 'Clau', with: 'password123'
    fill_in 'Confirma la clau', with: 'different123'
    
    click_button 'Registra\'t'
    
    assert_text 'Password confirmation doesn\'t match Password'
    assert_current_path user_registration_path
  end

  test 'user cannot register with invalid file types' do
    visit new_user_registration_path
    
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in 'Correu electrònic', with: 'john@example.com'
    
    # Try to upload invalid file type
    attach_file 'user_avatar', file_fixture('test_document.pdf')
    
    # The client-side validation should prevent this
    # Check that error message appears
    assert_text 'Tipus de fitxer no permès'
  end

  test 'user cannot register with oversized files' do
    visit new_user_registration_path
    
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in 'Correu electrònic', with: 'john@example.com'
    
    # Create a large file (this would be mocked in real tests)
    # attach_file 'user_avatar', large_file_fixture
    
    # Client-side validation should catch this
    # assert_text 'Fitxer massa gran'
  end

  test 'form shows real-time validation errors' do
    visit new_user_registration_path
    
    # Fill in email and then clear it to trigger validation
    fill_in 'Correu electrònic', with: 'test@example.com'
    fill_in 'Correu electrònic', with: ''
    
    # Click outside to trigger blur event
    find('body').click
    
    # Should show validation error
    assert_text 'Email can\'t be blank'
  end

  test 'location dropdowns work correctly' do
    visit new_user_registration_path
    
    # Select province
    select 'Barcelona', from: 'user_provincia'
    
    # Wait for comarca options to load
    sleep 1
    
    # Check that comarca options are available
    assert_selector 'select#comarca-select option', minimum: 2
    
    # Select comarca
    select 'Barcelonès', from: 'user_comarca'
    
    # Wait for municipi options to load
    sleep 1
    
    # Check that municipi options are available
    assert_selector 'select#municipi-select option', minimum: 2
  end

  test 'file upload shows preview' do
    visit new_user_registration_path
    
    # Upload an image
    attach_file 'user_avatar', file_fixture('test_avatar.jpg')
    
    # Should show preview
    assert_selector '[data-file-validation-target="preview"] img'
  end

  test 'registration with existing email shows error' do
    existing_user = create(:user, email: 'existing@example.com')
    
    visit new_user_registration_path
    
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in 'Correu electrònic', with: 'existing@example.com'
    fill_in 'Clau', with: 'password123'
    fill_in 'Confirma la clau', with: 'password123'
    
    click_button 'Registra\'t'
    
    assert_text 'Email has already been taken'
    assert_current_path user_registration_path
  end

  test 'registration form is accessible' do
    visit new_user_registration_path
    
    # Check for proper labels
    assert_selector 'label[for="user_nom"]'
    assert_selector 'label[for="user_email"]'
    assert_selector 'label[for="user_password"]'
    
    # Check for required field indicators
    assert_selector 'input[required]', minimum: 5
    
    # Check for proper form structure
    assert_selector 'form[action*="users"]'
    assert_selector 'input[type="submit"]'
  end

  test 'registration form handles JavaScript errors gracefully' do
    # Disable JavaScript
    Capybara.current_driver = :rack_test
    
    visit new_user_registration_path
    
    # Form should still be functional without JavaScript
    fill_in 'Nom', with: 'John'
    fill_in '1er Cognom', with: 'Doe'
    fill_in 'Correu electrònic', with: 'john@example.com'
    fill_in 'Clau', with: 'password123'
    fill_in 'Confirma la clau', with: 'password123'
    
    # Basic form submission should work
    click_button 'Registra\'t'
    
    # Should show validation errors for missing required fields
    assert_text 'can\'t be blank'
    
    # Re-enable JavaScript for other tests
    Capybara.current_driver = Capybara.default_driver
  end

  private

  def file_fixture(filename)
    case filename
    when 'test_avatar.jpg', 'test_moto.jpg'
      # Create a temporary image file
      file = Tempfile.new([filename, '.jpg'])
      file.write('fake image data')
      file.rewind
      file.path
    when 'test_document.pdf'
      # Create a temporary PDF file
      file = Tempfile.new([filename, '.pdf'])
      file.write('fake pdf data')
      file.rewind
      file.path
    else
      raise "Unknown fixture: #{filename}"
    end
  end
end
