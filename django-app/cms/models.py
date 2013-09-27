from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class BaseUser(User):
	iq = models.PositiveIntegerField()

	# class Meta:
	# 	abstract = True

class Student(BaseUser):
	pass

class Instructor(BaseUser):
	pass

class Course(models.Model):
	name = models.CharField(max_length=400)
	instructor = models.ForeignKey(Instructor)
	students = models.ManyToManyField(Student)

class Document(models.Model):
	title = models.CharField(max_length=200)
	author = models.ForeignKey(BaseUser)
	createdOn = models.DateTimeField()

class Link(models.Model):
	name = models.CharField(max_length=200)
	url = models.URLField()
	document = models.ForeignKey(Document, verbose_name="related document")

class DocumentComponents(models.Model):
	description = models.CharField(max_length=400)

class ImageComponent(DocumentComponents):
	image = models.ImageField(upload_to="image-uploads/")

class Syllabus(Document):
	course = models.OneToOneField(Course)

class Lesson(Document):
	week = models.PositiveIntegerField()
	course = models.ForeignKey(Course)

class Assignment(Document):
	dueOn = models.DateTimeField()
	points = models.DecimalField(max_digits=5, decimal_places=2)
	lesson = models.ForeignKey(Lesson)