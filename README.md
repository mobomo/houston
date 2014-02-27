# Welcome to Houston
Houston is a central hub for all things _your company,_ from upcoming projects to who's here:

- Plan projects on a beautiful interactive timeline
- See who's out this week and next
- Submit and approve leave requests
- Browse the company handbook
- Meant for project managers, CEO's, developers, designers—anyone part of your team's success!

## Setup

1. Copy `config/database.yml.template` to `config/database.yml` and edit it to match your PostgreSQL configuration

2. Run these commands in a terminal:
```
bundle install
bundle exec rake db:setup
```
3. Run `./script/rails s`

## Under the hood
Houston is built with:

- Rails 3.2
- Ruby 2.0
- Postgres
- Heroku
- D3, Sass, Coffeescript, and a whole lot more


## Getting started with Projects
Projects are added and managed via a Google spreadsheet that you create. The spreadsheet format allows you to easily forecast weekly hours from your team over several months.

To get started with a template, visit https://docs.google.com/a/intridea.com/spreadsheet/ccc?key=0AhF447tnvlZRdEd4elVJbWptS0hfS1RpSjQyZmVMMXc&usp=drive_web and **copy** the sheet to your own organization. Next:

1. While logged in as a SuperAdmin, visit **Schedules** from the navigation menu.
2. From the dropdown menu at the top of the page, select "Reload RAW data manually." This will _import_ all the projects and people from your spreadsheet.
3. That's it!

### Make it recurring:
You can configure your app to regularly import your spreadsheet by adding a cron job. Just ask the cron job to run the following rake task:

```
rake daily_pull_raw_data
```
## Getting started with Users
Users can be "bulk added" by simplying adding them to your Google spreadsheet. Upon import, those users will automagically get created. However, if you want to enable them to log into Houston, you'll have to visit **Users** from the menu and fill in their Google email addresses (be sure to use the email they use to log in, and *not* an email alias).


## Integration with HipChat Hubot for submitting FAQ's
* Configure the API key on your Houston instance by visiting **Settings**
* Add the key for Houston to your Hubot instance
  `heroku config:set HUBOT_DASHBOARD_API_KEY=SECRET_KEY`
* Add the houston hubot script to your Hubot instance
* Also set the dashboard url for your Hubot instance
  `heroku config:set HUBOT_DASHBOARD_URL=dashboard_url`
* Configure your Confluence account by visiting **Settings**
* HipChat Hubot commands are:
  * @hubot #tellme How do I submit a PTO request?
  * @hubot #tellyou #<question_id> Use the leave request form.
  * @hubot #showme <question_id>

