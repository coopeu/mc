# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = build(:user)
  end

  # Basic validations
  test 'should be valid with valid attributes' do
    assert @user.valid?
  end

  test 'should require email' do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test 'should require unique email' do
    create(:user, email: 'test@example.com')
    @user.email = 'test@example.com'
    assert_not @user.valid?
    assert_includes @user.errors[:email], 'has already been taken'
  end

  test 'should require valid email format' do
    invalid_emails = ['invalid', 'test@', '@example.com', 'test.example.com']
    invalid_emails.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email} should be invalid"
    end
  end

  test 'should require password' do
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test 'should require password confirmation' do
    @user.password = 'password123'
    @user.password_confirmation = 'different'
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], "doesn't match Password"
  end

  test 'should require minimum password length' do
    @user.password = @user.password_confirmation = 'short'
    assert_not @user.valid?
    assert_includes @user.errors[:password], 'is too short (minimum is 6 characters)'
  end

  # Profile validations
  test 'should require nom' do
    @user.nom = nil
    assert_not @user.valid?
    assert_includes @user.errors[:nom], "can't be blank"
  end

  test 'should require data_naixement' do
    @user.data_naixement = nil
    assert_not @user.valid?
    assert_includes @user.errors[:data_naixement], "can't be blank"
  end

  test 'should require mobil' do
    @user.mobil = nil
    assert_not @user.valid?
    assert_includes @user.errors[:mobil], "can't be blank"
  end

  test 'should require unique mobil' do
    create(:user, mobil: '123456789')
    @user.mobil = '123456789'
    assert_not @user.valid?
    assert_includes @user.errors[:mobil], 'has already been taken'
  end

  test 'should require moto_marca with minimum length' do
    @user.moto_marca = 'AB'
    assert_not @user.valid?
    assert_includes @user.errors[:moto_marca], 'is too short (minimum is 3 characters)'
  end

  test 'should require moto_model with minimum length' do
    @user.moto_model = 'AB'
    assert_not @user.valid?
    assert_includes @user.errors[:moto_model], 'is too short (minimum is 3 characters)'
  end

  test 'should require presentacio' do
    @user.presentacio = nil
    assert_not @user.valid?
    assert_includes @user.errors[:presentacio], "can't be blank"
  end

  test 'should limit presentacio length' do
    @user.presentacio = 'a' * 5001
    assert_not @user.valid?
    assert_includes @user.errors[:presentacio], 'is too long (maximum is 5000 characters)'
  end

  # File upload validations
  test 'should accept valid avatar image' do
    @user.avatar.attach(
      io: StringIO.new('fake image data'),
      filename: 'avatar.jpg',
      content_type: 'image/jpeg'
    )
    assert @user.valid?
  end

  test 'should reject avatar with invalid content type' do
    @user.avatar.attach(
      io: StringIO.new('fake file data'),
      filename: 'document.pdf',
      content_type: 'application/pdf'
    )
    assert_not @user.valid?
    assert_includes @user.errors[:avatar], 'ha de ser una imatge vàlida'
  end

  test 'should reject avatar with invalid file extension' do
    @user.avatar.attach(
      io: StringIO.new('fake image data'),
      filename: 'avatar.txt',
      content_type: 'image/jpeg'
    )
    assert_not @user.valid?
    assert_includes @user.errors[:avatar], 'ha de tenir una extensió vàlida'
  end

  test 'should reject oversized avatar' do
    large_file = StringIO.new('x' * 4.megabytes)
    @user.avatar.attach(
      io: large_file,
      filename: 'large_avatar.jpg',
      content_type: 'image/jpeg'
    )
    assert_not @user.valid?
    assert_includes @user.errors[:avatar], 'és massa gran'
  end

  test 'should accept valid foto_moto image' do
    @user.foto_moto.attach(
      io: StringIO.new('fake image data'),
      filename: 'moto.jpg',
      content_type: 'image/jpeg'
    )
    assert @user.valid?
  end

  test 'should reject foto_moto with malicious content' do
    malicious_content = StringIO.new("\x4D\x5A" + 'fake executable data')
    @user.foto_moto.attach(
      io: malicious_content,
      filename: 'moto.jpg',
      content_type: 'image/jpeg'
    )
    assert_not @user.valid?
    assert_includes @user.errors[:foto_moto], 'conté contingut potencialment perillós'
  end

  # Association tests
  test 'should belong to plan' do
    assert_respond_to @user, :plan
    assert_kind_of Plan, @user.plan
  end

  test 'should have many inscripcios' do
    assert_respond_to @user, :inscripcios
  end

  test 'should have many sortides through inscripcios' do
    assert_respond_to @user, :sortides
  end

  # Stripe integration tests
  test 'should create stripe customer after creation' do
    VCR.use_cassette('user_create_stripe_customer') do
      customer = build(:stripe_customer, email: @user.email)
      mock_stripe_request(:post, '/v1/customers', customer)

      @user.save!
      
      assert_equal 'cus_test_123', @user.stripe_customer_id
    end
  end

  test 'should handle stripe customer creation failure' do
    VCR.use_cassette('user_stripe_customer_failure') do
      error_response = {
        error: {
          type: 'api_error',
          message: 'Service temporarily unavailable'
        }
      }
      mock_stripe_request(:post, '/v1/customers', error_response, 500)

      # Should still save user even if Stripe fails
      assert @user.save
      assert_nil @user.stripe_customer_id
    end
  end

  # Subscription status tests
  test 'should check subscription status' do
    @user.subscription_status = 'active'
    assert @user.subscription_active?

    @user.subscription_status = 'canceled'
    assert_not @user.subscription_active?

    @user.subscription_status = 'past_due'
    assert_not @user.subscription_active?
  end

  # Friendly ID tests
  test 'should generate slug from name' do
    @user.nom = 'John'
    @user.cognoms = 'Doe'
    @user.save!
    
    assert_not_nil @user.slug
    assert_includes @user.slug, 'john'
  end

  test 'should handle duplicate slugs' do
    user1 = create(:user, nom: 'John', cognoms: 'Doe')
    user2 = build(:user, nom: 'John', cognoms: 'Doe')
    
    user2.save!
    
    assert_not_equal user1.slug, user2.slug
  end

  # Geocoding tests
  test 'should geocode address when changed' do
    @user.provincia = 'Barcelona'
    @user.comarca = 'Barcelonès'
    @user.municipi = 'Barcelona'
    
    # Mock geocoding response
    Geocoder::Lookup::Test.add_stub(
      'Barcelona, Barcelonès, Barcelona', 
      [{ 'latitude' => 41.3851, 'longitude' => 2.1734 }]
    )
    
    @user.save!
    
    assert_equal 41.3851, @user.latitude
    assert_equal 2.1734, @user.longitude
  end

  # Puntuacio association tests
  test 'should create puntuacio after user creation' do
    @user.save!
    assert_not_nil @user.puntuacio
  end

  test 'should destroy dependent records' do
    @user.save!
    puntuacio_id = @user.puntuacio.id
    
    @user.destroy
    
    assert_nil Puntuacio.find_by(id: puntuacio_id)
  end
end
