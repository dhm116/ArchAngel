from django.contrib import admin
import models

class ProfileInline(admin.TabularInline):
	model = models.UserProfile

class BaseUserInline(admin.TabularInline):
	model = models.BaseUser

class DocumentInline(admin.TabularInline):
	model = models.Document

class CourseInline(admin.TabularInline):
	model = models.Course

class LessonInline(admin.TabularInline):
	model = models.Lesson

class AssignmentInline(admin.TabularInline):
	model = models.Assignment
	fk_name = 'lesson'

class SyllabusInline(admin.TabularInline):
	model = models.Syllabus
	max_num = 1

class StudentAdmin(admin.ModelAdmin):
	model = models.Student

	inlines = [
		BaseUserInline,
		ProfileInline,
	]

class InstructorAdmin(admin.ModelAdmin):
	model = models.Instructor

	inlines = [
		BaseUserInline,
		ProfileInline,
	]

class CourseAdmin(admin.ModelAdmin):
	model = models.Course

	inlines = [
		LessonInline,
		SyllabusInline,
	]

class SyllabusAdmin(admin.ModelAdmin):
	model = models.Syllabus

	inlines = [
		BaseUserInline,
		CourseInline,
		# DocumentInline,
	]

class LessonAdmin(admin.ModelAdmin):
	model = models.Lesson

	inlines = [
		# DocumentInline,
		BaseUserInline,
		AssignmentInline,
		CourseInline,
	]

class AssignmentAdmin(admin.ModelAdmin):
	model = models.Assignment

	inlines = [
		LessonInline,
		BaseUserInline,
	]

admin.site.register(models.Instructor, InstructorAdmin)
admin.site.register(models.Student, StudentAdmin)
admin.site.register(models.Course, CourseAdmin)
admin.site.register(models.Syllabus, SyllabusAdmin)
admin.site.register(models.Lesson, LessonAdmin)
admin.site.register(models.Assignment, AssignmentAdmin)
