define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Grade', ($q, Restangular) ->
        class Grade extends ServiceBase
            model: 'gradedassignmentsubmission'
        return new Grade(Restangular, $q)


# define ['angular'], (angular) ->
#     angular.module('djangoApp.services').factory 'Grade', ($q, Grade, Restangular) ->
#         class Grade
#             grades: []

#             get: (ids) =>
#                 d = $q.defer()

#                 if typeof ids is 'string'
#                     ids = [ids]

#                 unless @grades.length
#                     console.log "Loading course grades"
#                     Restangular.all('grades').getList().then (grades) =>
#                         @grades = grades
#                         d.resolve(@__getGrades(ids))
#                 else
#                     d.resolve(@__getGrades(ids))
#                 return d.promise

#             __getGrades: (ids) =>
#                 return _.filter @grades, (grade) =>
#                     _.contains(ids, grade.id)


#         return new Grade()
