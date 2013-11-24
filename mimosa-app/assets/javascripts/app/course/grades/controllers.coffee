# define ['angular'], (angular) ->
#     return angular.module('djangoApp.controllers').controller 'LessonController',
#         ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Assignment) ->

#             Course.get(Number($routeParams.parentId)).then (course) ->
#                 $scope.course = course
#                 Course.isInstructorFor(course.id).then (isInstructor) ->
#                     $scope.isInstructor = isInstructor

#             $scope.action = $routeParams.action[0].toUpperCase() + $routeParams.action[1..-1]

#             $scope.lessons = []
#             $scope.assignments = []

#             # Only attempt to load lessons for this course
#             # if there are any
#             if $scope.course.lessons.length > 0
#                     Lesson.all($scope.course.lessons).then (lessons) ->
#                         $scope.lessons = lessons

                # loop through lessons for assignments        
                # if $scope.lesson.assignments.length > 0
                #         Assignment.all($scope.lesson.assignments).then (assignments) ->
                #             $scope.assignments = assignments

# student, author of assignment submission
# instructor, author of assignment