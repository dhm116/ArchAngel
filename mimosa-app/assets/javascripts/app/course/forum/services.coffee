define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Forum', ($q, $rootScope, Restangular) ->
        class Forum extends ServiceBase
            model: 'forums'
        return new Forum(Restangular, $q, $rootScope)
    angular.module('djangoApp.services').factory 'ForumPost', ($q, $rootScope, Restangular) ->
        class ForumPost extends ServiceBase
            model: 'forumposts'
        return new ForumPost(Restangular, $q, $rootScope)
        # class Lesson
        #     lessons: []

        #     get: (ids) =>
        #         d = $q.defer()
        #         unless Array.isArray(ids)
        #             ids = [ids]

        #         unless @lessons.length
        #             console.log "Loading course lessons"
        #             Restangular.all('lessons').getList().then (lessons) =>
        #                 @lessons = lessons
        #                 d.resolve(@__getLesson(ids))
        #         else
        #             d.resolve(@__getLesson(ids))
        #         return d.promise

        #     __getLesson: (ids) =>
        #         unless _.every(ids, _.isNumber)
        #             return ids

        #         return _.filter @lessons, (lesson) =>
        #             _.contains(ids, lesson.id)


        # return new Lesson()
