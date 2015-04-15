class SchedulesController < ApplicationController
  before_action :load_schedules

  before_action :require_login, only: [:index, :show, :calendar]
  before_action(only: [:new, :create, :edit, :update, :destroy]) do |c|
    c.require_group_or_id :admin, @student.id
  end

  # get|post /calendar
  def calendar
    # persist user's calendar options
    session[:calendar] ||= HashWithIndifferentAccess.new
    session[:calendar].merge!(params[:calendar] || {})

    @calendar = ScheduleCalendar.new(session[:calendar])

    respond_to do |format|
      format.js
      format.html
    end
  end

  def index
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
  end

  def new
    @schedule = @student.schedules.new

    # sensible defaults
    @schedule.start_date = Date.today
    @schedule.start_time = Time.new(2001,1,1,9) # 9:00 AM
    @schedule.end_time = Time.new(2001,1,1,12)  # 12:00 PM

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @schedule }
    end
  end

  def edit
  end

  def create
    @schedule = @student.schedules.new(schedule_params)

    respond_to do |format|
      if @schedule.save

        # send notification email
        Student.where(group: 'admin').push(@student).each do |recipient|
          ServiceMailer.created_schedule_email(recipient, @student, current_user, @schedule).deliver unless recipient.mail.nil?
        end

        format.html { redirect_to [@student, @schedule], notice: 'Schedule was successfully created.' }
        format.json { render json: @schedule, status: :created, location: @schedule }
      else
        format.html { render action: "new" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    old_schedule = @schedule.dup # save the old schedule before it updates to send it to the mailer

    respond_to do |format|
      if @schedule.update_attributes(schedule_params)

        # send notification email
        Student.where(group: 'admin').push(@student).each do |recipient|
          ServiceMailer.updated_schedule_email(recipient, @student, current_user, old_schedule, @schedule).deliver unless recipient.mail.nil?
        end

        format.html { redirect_to [@student, @schedule], notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # save the old schedule before it is deleted to send it to the mailer
    old_schedule = @schedule.dup
    @schedule.destroy

    # send notification email
    Student.where(group: 'admin').push(@student).each do |recipient|
      ServiceMailer.deleted_schedule_email(recipient, @student, current_user, old_schedule).deliver unless recipient.mail.nil?
    end

    respond_to do |format|
      format.html { redirect_to @student }
      format.json { head :no_content }
    end
  end

  private

  def load_schedules
      @student = Student.find(params[:student_id]) if params[:student_id]
      if params[:id]
        schedule = Schedule.find(params[:id])
        @schedule = SchedulePresenter.new schedule
      end
      if params[:ids]
        schedules = Schedule.find(params[:ids])
        @schedules = SchedulePresenter.wrap schedules
      end
  end

  def schedule_params
    params.require(:schedule).permit(:description, :end_date, :end_time,
      :friday, :monday, :saturday, :start_date, :start_time, :group,
      :student_id, :sunday, :thursday, :tuesday, :wednesday)
  end
end
