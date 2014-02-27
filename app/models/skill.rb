class Skill < ActiveRecord::Base
  attr_accessible :importance, :name

  validates :name, presence: true

  has_many :experiences
  has_many :users, :through => :experiences

  has_many :required_skills
  has_many :projects, :through => :required_skills

  class <<self
    def text_search query
      if query.present?
        #where "name @@ :q", q: query
        queries = []
        query.split.each {|q|
          queries << "name @@ '#{q}'"
        }
        where queries.join(" or ")
      else
        scoped
      end
    end

    # collection is either users or projects
    def matching(target, collection)
      sample = collection.first
      return [] unless sample.respond_to?(:skill_ids) && sample.respond_to?(:name)

      collection
        .map {|obj| [obj.name, (obj.skill_ids & target.skill_ids).length] }
        .sort {|a, b| b[1] <=> a[1] }
    end
  end

end
