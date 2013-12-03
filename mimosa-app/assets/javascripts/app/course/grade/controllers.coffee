define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'GradedAssignmentSubmissionController',
        ($scope, $routeParams, $location, Restangular, User, Course, CourseRoster, CourseSection, Lesson, Assignment, AssignmentSubmission, GradedAssignmentSubmission) ->
            # Keep track of what model we're loading
            params = _.last($routeParams.resources)

            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
            assignmentParams = _.findWhere($routeParams.resources, {resource:'assignment'})
            submissionParams = _.findWhere($routeParams.resources, {resource:'submission'})
            gradeParams = _.findWhere($routeParams.resources, {resource:'grade'})

            $scope.resource = params.resource
            $scope.action = gradeParams.action[0].toUpperCase() + gradeParams.action[1..-1]
            $scope.moment = moment
            $scope._ = _
            $scope.User = User

            if courseParams
                Course.get(Number(courseParams.id)).then (course) ->
                    # $scope.course = course
                    Course.isInstructorFor(course.id).then (isInstructor) ->
                        $scope.isInstructor = isInstructor

                    Lesson.get(Number(lessonParams.id)).then (lesson) ->
                        # $scope.lesson = lesson

                        Assignment.get(Number(assignmentParams.id)).then (assignment) ->
                            $scope.assignment = assignment
                            $('#points').spinner({min: 0, max: assignment.points});
                            $('#points').on 'changed', (e, val) ->
                                $scope.$apply ->
                                    $scope.gradedassignmentsubmission.score = val

                            AssignmentSubmission.get(Number(submissionParams.id)).then (submission) ->
                                $scope.submission = submission

                                unless gradeParams.action.indexOf('edit') is 0
                                    $scope.gradedassignmentsubmission = {
                                        score: $scope.assignment.points
                                        author: User.data.id
                                        submission: submission.id
                                        name: "Graded on #{moment().format('LL')}"
                                    }
                                    $('#points').spinner('value', $scope.gradedassignmentsubmission.score)
                                else
                                    GradedAssignmentSubmission.get(Number(gradeParams.id)).then (gradedassignmentsubmission) ->
                                        $scope.gradedassignmentsubmission = gradedassignmentsubmission

                                        $('#points').spinner('value', $scope.gradedassignmentsubmission.score)

            Course.all().then (courses) ->
                $scope.courses = courses
                $scope.isInstructorFor = {}
                for course in courses
                    preserveCourse = (course) ->
                        Course.isInstructorFor(course.id).then (result) ->
                            $scope.isInstructorFor[course.id] = result
                    preserveCourse(course)

            CourseSection.all().then (sections) ->
                $scope.sections = _.indexBy(sections, 'id')
                $scope.course_sections = _.groupBy(sections, 'course')

            CourseRoster.students().then (students) ->
                $scope.course_students = _.groupBy(students, 'course')

            Lesson.all().then (lessons) ->
                $scope.lessons = _.indexBy(lessons, 'id')
                $scope.course_lessons = _.groupBy(lessons, 'course')

            Assignment.all().then (assignments) ->
                $scope.assignments = _.indexBy(assignments, 'id')
                $scope.lesson_assignments = _.groupBy(assignments, 'lesson')

            AssignmentSubmission.all().then (submissions) ->
                $scope.submissions = submissions
                $scope.assignment_submissions = _.groupBy(submissions, 'assignment')
                $scope.student_submissions = _.groupBy(submissions, 'author')

            GradedAssignmentSubmission.all().then (grades) ->
                $scope.grades = _.indexBy(grades, 'submission')

            User.all().then (users) ->
                $scope.users = _.indexBy(users, 'id')

            $scope.getStudentSubmission = (userId, assignmentId) ->
                unless $scope.student_submissions
                    return null
                else
                    return _.findWhere($scope.student_submissions[userId], {assignment: assignmentId})

            $scope.averageGrade = (assignment) ->
                unless $scope.assignment_submissions
                    return null
                submissions = $scope.assignment_submissions[assignment.id]
                unless submissions
                    return null
                unless $scope.grades
                    return null
                submissionIds = _.pluck(submissions, 'id')
                grades = _.filter $scope.grades, (grade) ->
                    return submissionIds.indexOf(grade.submission) > -1
                unless grades
                    return null
                sum = _.reduce(
                    grades,
                    (memo, grade) ->
                        return Number(grade.score)+Number(memo)
                    , 0)
                average = sum/grades.length
                return average*100/assignment.points

            $scope.cumulativeGrade = (course) ->
                unless $scope._cumulativeGrade
                    $scope._cumulativeGrade = {}

                if $scope._cumulativeGrade[course.id]
                    return $scope._cumulativeGrade[course.id]

                totalScore = 0
                totalPoints = 0

                unless $scope.course_lessons && $scope.lesson_assignments && $scope.assignment_submissions && $scope.grades
                    return {score: totalScore, points: totalPoints, percent: 0}

                lessonIds = _.pluck($scope.course_lessons[course.id], 'id')

                for id in lessonIds
                    assignments = $scope.lesson_assignments[id]

                    if assignments?.length > 0
                        totalPoints += Number(a.points) for a in assignments

                        assignmentIds = _.pluck(assignments, 'id')

                        for aId in assignmentIds
                            submissions = $scope.assignment_submissions[aId]

                            if submissions
                                for sId in _.pluck(submissions, 'id')
                                    grade = $scope.grades[sId]
                                    if grade
                                        totalScore += Number(grade.score)

                $scope._cumulativeGrade[course.id] = {score: totalScore, points: totalPoints, percent: totalScore/totalPoints*100}
                return $scope._cumulativeGrade[course.id]

            $scope.save = ->
                if gradeParams.action.indexOf("edit") is 0
                    console.log "Saving grade changes: ", $scope.gradedassignmentsubmission
                    GradedAssignmentSubmission.update($scope.gradedassignmentsubmission)
                        .then (result) ->
                            console.log "Save worked: ", result
                            # $scope.course.lessons.push result
                            $location.path("/grade/view/all")
                        .catch (err) ->
                            console.log "Save failed: ", err
                else if gradeParams.action.indexOf('add') is 0
                    console.log "Saving new Grade: ", $scope.gradedassignmentsubmission
                    GradedAssignmentSubmission.add($scope.gradedassignmentsubmission)
                        .then (result) ->
                            console.log "Adding worked: ", result
                            # $scope.lessons.push result
                            $scope.submission.grade.push(result.id)
                            $location.path("/grade/view/all")
                        .catch (err) ->
                            console.log "Adding failed: ", err
