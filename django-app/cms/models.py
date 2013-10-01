from django.db import models
from django.contrib.auth.models import User
from model_utils.managers import InheritanceManager
from django.contrib.contenttypes import generic

# Create your models here.
class BaseUser(User):
	userid = models.CharField(max_length=50)
	title = models.CharField(max_length=200, blank=True)
	objects = InheritanceManager()
	# class Meta:
	# 	abstract = True

class UserProfile(models.Model):
	bio = models.TextField(blank=True)
	picture = models.URLField(blank=True)
	user = models.OneToOneField(BaseUser, null=True)

class Student(BaseUser):

	class Meta:
		verbose_name = 'Student'
		verbose_name_plural = 'Students'

class Instructor(BaseUser):

	class Meta:
		verbose_name = 'Instructor'
		verbose_name_plural = 'Instructors'

class Course(models.Model):
	name = models.CharField(max_length=400)
	instructor = models.ForeignKey(Instructor, related_name='courses')
	students = models.ManyToManyField(Student, related_name='courses')

class Document(models.Model):
	title = models.CharField(max_length=200)
	author = models.ForeignKey(BaseUser)
	createdOn = models.DateTimeField(auto_now_add=True)
	objects = InheritanceManager()
	# course = models.ForeignKey(Course, related_name='documents')

class Link(models.Model):
	name = models.CharField(max_length=200)
	url = models.URLField()
	document = models.ForeignKey(Document, verbose_name="related document")

class DocumentComponents(models.Model):
	description = models.CharField(max_length=400)
	objects = InheritanceManager()

class ImageComponent(DocumentComponents):
	image = models.ImageField(upload_to="image-uploads/")

	class Meta:
		verbose_name = 'Image'
		verbose_name_plural = 'Images'

class Syllabus(Document):
	course = models.ForeignKey(Course, related_name='syllabus')

	class Meta:
		verbose_name = 'Syllabus'
		verbose_name_plural = 'Syllabuses'

class Lesson(Document):
	course = models.ForeignKey(Course, related_name='lessons')
	week = models.PositiveIntegerField()

	class Meta:
		verbose_name = 'Lesson'
		verbose_name_plural = 'Lessons'

class Assignment(Document):
	dueOn = models.DateTimeField()
	points = models.DecimalField(max_digits=5, decimal_places=2)
	lesson = models.ForeignKey(Lesson, related_name='assignments')

	class Meta:
		verbose_name = 'Assignment'
		verbose_name_plural = 'Assignments'
