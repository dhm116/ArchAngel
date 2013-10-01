from django.contrib.auth.models import User, Group
from models import *
from rest_framework import serializers
from django.db.models.fields import *

class UserSerializer(serializers.HyperlinkedModelSerializer):
	class Meta:
		model = User
		fields = ('url', 'id', 'username', 'email', 'groups')

class GroupSerializer(serializers.HyperlinkedModelSerializer):
	class Meta:
		model = Group
		fields = ('url', 'name')

class CourseSerializer(serializers.HyperlinkedModelSerializer):
	# documents = DocumentObjectRelatedField(many=True)#, context={'request':request})
	# syllabus = SyllabusSerializer()

	class Meta:
		model = Course
		fields = ('url', 'id', 'name', 'instructor', 'students', 'syllabus', 'lessons')
		depth = 1

class InstructorSerializer(serializers.HyperlinkedModelSerializer):
	class Meta:
		model = Instructor
		fields = ('url', 'id', 'username', 'email', 'groups', 'courses')

class StudentSerializer(serializers.HyperlinkedModelSerializer):
	class Meta:
		model = Student
		fields = ('url', 'id', 'username', 'email', 'groups', 'courses')

class DocumentSerializer(serializers.HyperlinkedModelSerializer):
	class Meta:
		model = Document
		fields = ('url', 'title',)

class SyllabusSerializer(serializers.HyperlinkedModelSerializer):
	#author = serializers.HyperlinkedRelatedField(view_name='instructor-detail')
	#course = serializers.HyperlinkedRelatedField(view_name='course-detail')

	class Meta:
		model = Syllabus
		fields = ('url', 'id', 'title', 'course', 'author', 'createdOn')
		depth = 1

class LessonSerializer(serializers.HyperlinkedModelSerializer):
	#author = UserSerializer() #serializers.HyperlinkedRelatedField(view_name='instructor-detail')
	#course = serializers.RelatedField() #serializers.HyperlinkedRelatedField(view_name='course-detail')
	#assignments = serializers.HyperlinkedRelatedField(view_name='assignment-detail', many=True)

	class Meta:
		model = Lesson
		fields = ('url', 'id', 'title', 'week', 'course', 'author', 'createdOn', 'assignments')
		depth = 1

class AssignmentSerializer(serializers.HyperlinkedModelSerializer):
	author = serializers.HyperlinkedRelatedField(view_name='instructor-detail')
	lesson = serializers.HyperlinkedRelatedField(view_name='lesson-detail')

	class Meta:
		model = Assignment
		fields = ('url', 'id', 'title', 'dueOn', 'points', 'lesson', 'author')

class DocumentObjectRelatedField(serializers.RelatedField):
	def to_native(self, value):
		if isinstance(value, Syllabus):
			serializer = SyllabusSerializer(value)
		elif isinstance(value, Lesson):
			serializer = LessonSerializer(value)
		elif isinstance(value, Assignment):
			serializer = AssignmentSerializer(value)
		elif isinstance(value, Document):
			serializer = DocumentSerializer(value)
		else:
			raise Exception('Unexpected type of document object: ' + value.__class__.__name__)
		#serializer.data['__type__'] = value.__class__.__name__
		return serializer.data
