# == Schema Information
#
# Table name: seamails
#
#  id          :bigint           not null, primary key
#  last_update :datetime         not null
#  subject     :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_seamails_subject  (to_tsvector('english'::regconfig, (subject)::text)) USING gin
#

class Seamail < ApplicationRecord
  include Searchable

  has_many :seamail_messages, -> { order(:id) }, class_name: 'SeamailMessage', inverse_of: :seamail
  has_many :user_seamails, inverse_of: :seamail, dependent: :destroy
  has_many :users, through: :user_seamails

  validates :subject, presence: true, length: { maximum: 200 }
  validate :validate_users
  validate :validate_messages

  def validate_users
    errors[:base] << 'Must send seamail to another user of Twit-arr' unless usernames.count > 1
    usernames.each do |username|
      errors[:base] << "#{username} is not a valid username" unless User.exist? username
    end
  end

  def validate_messages
    errors[:base] << 'Must include a message' if messages.empty?
    seamail_messages.each do |message|
      message.errors.full_messages.each { |x| errors[:base] << x } unless message.valid?
    end
  end

  def usernames=(usernames)
    super usernames.map { |x| User.format_username x }
  end

  def subject=(subject)
    super subject&.strip
  end

  def last_message
    last_update
  end

  def seamail_count
    seamail_messages.count
  end

  def mark_as_read(username)
    user_seamails.where(user_id: User.get(username).id).update(last_viewed: DateTime.now)
  end

  def self.create_new_seamail(author, to_users, subject, first_message_text, original_author)
    right_now = Time.now
    to_users ||= []
    to_users = to_users.map(&:downcase).uniq
    to_users << author unless to_users.include? author

    seamail = Seamail.new(subject: subject, last_update: right_now)
    seamail.seamail_messages << SeamailMessage.new(author: User.get(author).id, text: first_message_text, original_author: User.get(original_author).id)

    recipients = User.where(username: to_users)
    recipients.each do |recipient|
      user_seamail = UserSeamail.new(user_id: recipient.id)
      user_seamail.last_viewed = right_now if recipient.username == author
      seamail.user_seamails << user_seamail
    end

    seamail.save if seamail.valid?
    seamail
  end

  def add_message(author, text, original_author)
    right_now = Time.now
    self.last_update = right_now
    author_id = User.get(author).id
    seamail_messages << SeamailMessage.new(author: author_id, text: text, original_author: User.get(original_author).id)
    user_seamails.where(user_id: author_id).update(last_viewed: right_now)
    save
  end

  def self.search(params = {})
    search_text = params[:query].strip.downcase.gsub(/[^\w&\s@-]/, '')
    current_username = params[:current_username]
    criteria = Seamail.where(usernames: current_username).or({ usernames: /^#{search_text}.*/ },
                                                             '$text' => { '$search' => "\"#{search_text}\"" })
    limit_criteria(criteria, params).order(last_update: :desc)
  end

end
