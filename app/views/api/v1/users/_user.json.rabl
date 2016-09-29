object :@current_user

attributes :id, :name, :display_name, :email, :created_at, :updated_at

node(:fb_profile_pic_url) { "https://graph.facebook.com/" + @external_auth.uid + "/picture?width=" + @size + "&height=" + @size }
