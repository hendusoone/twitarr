class AnnouncementDecorator < BaseDecorator
  delegate_all
  include Twitter::Autolink

  def to_hash
    {
        id: as_str(id),
        author: {
          username: author,
          display_name: User.display_name_from_username(author),
          last_photo_updated: User.last_photo_updated_from_username(author).to_ms
        },
        text: twitarr_auto_linker(text.gsub("\n", '<br />')),
        timestamp: timestamp.to_ms
    }
  end

  def to_admin_hash
    {
        id: as_str(id),
        author: author,
        text: text,
        timestamp: timestamp.to_ms,
        valid_until: valid_until.to_ms
    }
  end

end