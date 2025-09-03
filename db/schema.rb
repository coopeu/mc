# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_27_181732) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "cart_items", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "secret_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false, collation: "utf8mb3_general_ci"
    t.string "description", limit: 512, collation: "utf8mb3_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "channels", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "channel", default: "''", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_messages", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sortide_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sortide_id"], name: "index_chat_messages_on_sortide_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "comandes", charset: "utf8mb4", collation: "utf8mb4_general_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "producte_id", null: false
    t.integer "quantitat"
    t.string "talla", limit: 20
    t.string "color", limit: 20
    t.text "comentari"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["producte_id"], name: "producte_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "contactes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "nom", collation: "utf8mb3_bin"
    t.string "email", collation: "utf8mb3_bin"
    t.string "telefon", collation: "utf8mb3_bin"
    t.text "missatge", collation: "utf8mb3_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "donacios", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "import", null: false
    t.index ["user_id"], name: "user_id"
  end

  create_table "donations", charset: "utf8mb4", collation: "utf8mb4_general_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "nom", limit: 50, null: false
    t.integer "import", null: false
    t.string "tipus", limit: 50, null: false
    t.string "codi", limit: 50, null: false
    t.string "sku", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "product_id"
  end

  create_table "follows", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "following_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id", "following_id"], name: "index_follows_on_follower_id_and_following_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
    t.index ["following_id"], name: "index_follows_on_following_id"
  end

  create_table "forums", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "user_id"
    t.bigint "channel_id"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "channel_id"
    t.index ["slug"], name: "index_forums_on_slug", unique: true
    t.index ["user_id"], name: "index_forums_on_user_id"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "sortide_id", null: false
    t.text "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sortide_id"], name: "index_images_on_sortide_id"
  end

  create_table "inscripcios", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sortide_id", null: false
    t.datetime "created_at", default: -> { "current_timestamp(6)" }, null: false
    t.datetime "updated_at", default: -> { "current_timestamp(6)" }, null: false
    t.index ["sortide_id"], name: "index_inscriptions_on_sortide_id"
    t.index ["user_id"], name: "index_inscriptions_on_user_id"
  end

  create_table "liders", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "sortide_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sortide_id"], name: "index_liders_on_sortide_id"
    t.index ["user_id"], name: "index_liders_on_user_id"
  end

  create_table "likes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "likeable_type", null: false
    t.bigint "likeable_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "piulade_comments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "body"
    t.integer "piulade_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_piulades_on_user_id"
  end

  create_table "piulades", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "body"
    t.integer "piulade_id"
    t.bigint "user_id", null: false
    t.bigint "sortide_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_piulades_on_user_id"
  end

  create_table "plans", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "product_id"
    t.string "nom"
    t.string "accesWeb"
    t.integer "maxSortidesAny"
    t.decimal "preu", precision: 10, scale: 2
    t.integer "descompteInscripcions"
    t.integer "descompteBotiga"
    t.text "detalls"
    t.string "sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "id"
    t.index ["product_id"], name: "product_id"
  end

  create_table "posts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false, collation: "utf8mb3_bin"
    t.string "title", null: false, collation: "utf8mb3_bin"
    t.string "foto", default: "", null: false, collation: "utf8mb3_bin"
    t.text "content", null: false, collation: "utf8mb3_bin"
    t.bigint "category_id"
    t.string "slug", null: false, collation: "utf8mb3_bin"
    t.string "page", collation: "utf8mb3_bin"
    t.string "render", collation: "utf8mb3_bin"
    t.string "images", default: "''", null: false, collation: "utf8mb3_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "posts_20200420", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false, collation: "utf8mb3_bin"
    t.string "title", null: false, collation: "utf8mb3_bin"
    t.string "foto", default: "", null: false, collation: "utf8mb3_bin"
    t.text "content", null: false, collation: "utf8mb3_bin"
    t.bigint "category_id"
    t.string "slug", null: false, collation: "utf8mb3_bin"
    t.string "page", collation: "utf8mb3_bin"
    t.string "images", default: "''", null: false, collation: "utf8mb3_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "productes", charset: "utf8mb4", collation: "utf8mb4_general_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "nom", null: false
    t.text "descripcio"
    t.string "codi", limit: 50, null: false
    t.integer "preu", limit: 2, null: false
    t.string "specs"
    t.text "detalls"
    t.string "color", limit: 50
    t.string "talla", limit: 50
    t.string "proveidor", limit: 50
    t.string "comanda"
    t.string "distribucio"
    t.string "sku", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "tipus", null: false
    t.string "nom"
    t.string "num_dies"
    t.integer "plan_id", limit: 2
    t.decimal "preu", precision: 10
    t.string "specs"
    t.string "detalls"
    t.string "sku", limit: 25
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "puntsinis", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "tipus_carnet"
    t.string "anys_carnet"
    t.string "kms"
    t.string "num_sortides"
    t.string "grau_esportiu"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_puntsinis_on_user_id"
  end

  create_table "puntuacios", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.float "punts_ini"
    t.float "punts_act"
    t.integer "escalafo", limit: 1
    t.string "user_level", limit: 25
    t.datetime "calculated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_puntuacios_on_user_id"
  end

  create_table "purchases", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email", null: false
    t.bigint "product_id", null: false
    t.text "description", null: false
    t.integer "amount", null: false
    t.string "currency", null: false
    t.string "stripe_id"
    t.string "customer_id", null: false
    t.string "card", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid", null: false
    t.index ["product_id"], name: "product_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "ritmes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false, collation: "utf8mb3_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "login_time"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sortide_comments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.bigint "sortide_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sortide_id"], name: "index_sortide_comments_on_sortide_id"
    t.index ["user_id"], name: "index_sortide_comments_on_user_id"
  end

  create_table "sortideclasses", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "sortide_id"
    t.bigint "category_id"
    t.bigint "ritme_id"
    t.bigint "tipu_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "category_id"
    t.index ["ritme_id"], name: "ritme_id"
    t.index ["sortide_id"], name: "sortide_id"
    t.index ["tipu_id"], name: "tipu_id"
  end

  create_table "sortides", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", collation: "utf8mb3_bin"
    t.date "start_date"
    t.time "start_time"
    t.string "start_point", collation: "utf8mb3_general_ci"
    t.text "descripcio", collation: "utf8mb3_bin"
    t.string "ruta_foto", collation: "utf8mb3_bin"
    t.integer "Km", limit: 2
    t.string "slug", collation: "utf8mb3_bin"
    t.integer "min_inscrits", default: 4
    t.integer "max_inscrits", default: 9
    t.integer "num_dies", default: 1
    t.decimal "fi_ndies", precision: 10, default: "1"
    t.boolean "oberta"
    t.decimal "preu", precision: 10
    t.integer "approved", limit: 1
    t.string "sku", collation: "utf8mb3_bin"
    t.string "codi", collation: "utf8mb3_bin"
    t.string "youtube", default: "https://www.youtube.com/@clubmotoristamilrevolts/videos", collation: "utf8mb3_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_sortidas_on_slug", unique: true
    t.index ["user_id"], name: "user_id"
  end

  create_table "sortides00", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "title"
    t.date "start_time"
    t.text "descripcio"
    t.string "ruta_foto"
    t.string "render"
    t.string "slug"
    t.integer "max_inscrits", default: 9
    t.integer "min_inscrits", default: 4
    t.integer "num_dies", default: 1
    t.decimal "fi_ndies", precision: 2, scale: 1, default: "1.0"
    t.string "codi"
    t.string "sku"
    t.boolean "oberta"
    t.boolean "average_score", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_sortidas_on_slug", unique: true
  end

  create_table "sortides_fetes", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "title"
    t.date "start_date"
    t.text "descripcio"
    t.string "youtube_link"
    t.string "slug"
    t.integer "max_inscrits", default: 9
    t.integer "min_inscrits", default: 4
    t.integer "num_dies", default: 1
    t.decimal "fi_ndies", precision: 2, scale: 1, default: "1.0"
    t.string "codi"
    t.string "sku"
    t.boolean "oberta"
    t.boolean "average_score", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_sortidas_fetes_on_slug", unique: true
  end

  create_table "subscriptors", charset: "utf8mb4", collation: "utf8mb4_general_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipus", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false, collation: "utf8mb3_general_ci"
    t.string "description", limit: 512, collation: "utf8mb3_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "nom", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "cognom1", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "cognom2", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "moto_marca", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "moto_model", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "provincia", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "comarca", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "municipi", limit: 50, null: false, collation: "utf8mb3_bin"
    t.string "mobil", limit: 12, null: false, collation: "utf8mb3_bin"
    t.date "data_naixement", null: false
    t.string "email", null: false, collation: "utf8mb3_bin"
    t.text "presentacio", null: false, collation: "utf8mb3_bin"
    t.string "slug", collation: "utf8mb3_bin"
    t.bigint "plan_id", default: 0, null: false
    t.boolean "approved"
    t.boolean "baixa"
    t.string "stripe_customer_id", limit: 50
    t.string "stripe_email", limit: 50
    t.boolean "admin"
    t.string "encrypted_password", null: false, collation: "utf8mb3_bin"
    t.datetime "created_at", null: false
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "reset_password_token", collation: "utf8mb3_bin"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token", limit: 191, collation: "utf8mb3_bin"
    t.datetime "updated_at", null: false
    t.decimal "latitude", precision: 10
    t.decimal "longitude", precision: 10
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id"], name: "id"
    t.index ["mobil"], name: "mobil", unique: true
    t.index ["plan_id"], name: "index_user_on_plan_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "chat_messages", "sortides"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "comandes", "productes", name: "comandes_ibfk_2"
  add_foreign_key "comandes", "users", name: "comandes_ibfk_1"
  add_foreign_key "donacios", "users", name: "donacios_ibfk_2"
  add_foreign_key "donations", "products", name: "donations_ibfk_1"
  add_foreign_key "forums", "channels", name: "forums_ibfk_1"
  add_foreign_key "forums", "users"
  add_foreign_key "images", "sortides"
  add_foreign_key "inscripcios", "sortides"
  add_foreign_key "inscripcios", "users"
  add_foreign_key "liders", "sortides"
  add_foreign_key "liders", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "piulade_comments", "users"
  add_foreign_key "piulades", "users", name: "fk_piulades_user_id"
  add_foreign_key "plans", "products", name: "plans_ibfk_1"
  add_foreign_key "posts_20200420", "categories"
  add_foreign_key "posts_20200420", "users"
  add_foreign_key "productes", "plans01", column: "id", primary_key: "product_id", name: "productes_ibfk_1"
  add_foreign_key "puntsinis", "users"
  add_foreign_key "puntuacios", "users"
  add_foreign_key "purchases", "products", name: "purchases_ibfk_1"
  add_foreign_key "purchases", "users", name: "purchases_ibfk_2"
  add_foreign_key "sessions", "users"
  add_foreign_key "sortide_comments", "sortides"
  add_foreign_key "sortide_comments", "users"
  add_foreign_key "sortideclasses", "categories", name: "sortideclasses_ibfk_2"
  add_foreign_key "sortideclasses", "ritmes", name: "sortideclasses_ibfk_4"
  add_foreign_key "sortideclasses", "sortides", name: "sortideclasses_ibfk_5"
  add_foreign_key "sortideclasses", "tipus", name: "sortideclasses_ibfk_3"
  add_foreign_key "sortides", "users", name: "sortides_ibfk_1"
  add_foreign_key "users", "plans", name: "users_ibfk_1"
end
