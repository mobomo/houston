class Page < ConfluenceSoap::Page

  def self.all
    client.get_pages(default_space).map { |page| Page.from_hash(page.to_h) }
  end

  def self.all_questions
    client.get_children(faq_parent_id).map { |page| Page.from_hash(page.to_h) }
  end

  def self.find id
    Page.from_hash(client.get_page(id).to_h)
  end

  def self.recent_question
    conditions =
      "modified:[#{1.month.ago.strftime('%Y%m%d')} TO ?] and labelText:faq"
    pages = search(conditions)

    pages.present? ? pages.sample : all_questions.sample
  end

  def self.search query
    pages = client.search(query, {type: 'page', spaceKey: default_space})

    pages.map { |page| Page.from_hash(page.to_h) }
  end

  def save
    if id.blank?
      page = Page.client.store_page(self)
      Page.client.add_label_by_name('faq', page.id)
      page
    else
      Page.client.update_page(self)
    end
  end

  def destroy
    return false if id.blank?

    Page.client.remove_page(id)
  end

  def self.default_space
    Configuration::Confluence.settings[:space]
  end

  def self.faq_parent_id
    Configuration::Confluence.settings[:faq_parent]
  end

  def self.client
    Configuration::Confluence.client
  end
end
