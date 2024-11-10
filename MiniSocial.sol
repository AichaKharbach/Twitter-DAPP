// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniSocial {
    // Structure pour un Post
    struct Post {
        string message;
        address author;
        uint likeCount;
        uint commentCount;
        bool exists; // Indicateur pour savoir si le post existe
    }

    // Structure pour un Commentaire
    struct Comment {
        string message;
        address commenter;
        uint likeCount;
        bool exists; // Indicateur pour savoir si le commentaire existe
    }

    // Tableau pour stocker les posts
    Post[] public posts;
    
    // Mapping pour les likes des posts
    mapping(uint => mapping(address => bool)) public postLikes;
    
    // Mapping pour les commentaires d'un post (postId => array of Comments)
    mapping(uint => Comment[]) public postComments;
    
    // Mapping pour les likes sur les commentaires d'un post (postId => (commentIndex => (address => liked)))
    mapping(uint => mapping(uint => mapping(address => bool))) public commentLikes;

    // Fonction pour publier un nouveau post
    function publishPost(string memory _message) public {
        posts.push(Post({
            message: _message,
            author: msg.sender,
            likeCount: 0,
            commentCount: 0,
            exists: true
        }));
    }

    // Fonction pour liker un post
    function likePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(!postLikes[_postId][msg.sender], "You have already liked this post");

        postLikes[_postId][msg.sender] = true;
        posts[_postId].likeCount++;
    }

    // Fonction pour "unlike" un post
    function unlikePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(postLikes[_postId][msg.sender], "You haven't liked this post");

        postLikes[_postId][msg.sender] = false;
        posts[_postId].likeCount--;
    }

    // Fonction pour ajouter un commentaire sur un post
    function addComment(uint _postId, string memory _message) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");

        postComments[_postId].push(Comment({
            message: _message,
            commenter: msg.sender,
            likeCount: 0,
            exists: true
        }));
        posts[_postId].commentCount++;
    }

    // Fonction pour liker un commentaire d'un post
    function likeComment(uint _postId, uint _commentIndex) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");
        require(postComments[_postId][_commentIndex].exists, "Comment has been deleted");
        require(!commentLikes[_postId][_commentIndex][msg.sender], "You have already liked this comment");

        commentLikes[_postId][_commentIndex][msg.sender] = true;
        postComments[_postId][_commentIndex].likeCount++;
    }

    // Fonction pour "unlike" un commentaire
    function unlikeComment(uint _postId, uint _commentIndex) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");
        require(postComments[_postId][_commentIndex].exists, "Comment has been deleted");
        require(commentLikes[_postId][_commentIndex][msg.sender], "You haven't liked this comment");

        commentLikes[_postId][_commentIndex][msg.sender] = false;
        postComments[_postId][_commentIndex].likeCount--;
    }

    // Fonction pour supprimer un post (seul l'auteur peut le supprimer)
    function deletePost(uint _postId) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has already been deleted");
        require(posts[_postId].author == msg.sender, "You are not the author of this post");

        posts[_postId].exists = false;
        posts[_postId].likeCount = 0;
        posts[_postId].commentCount = 0;
    }

    // Fonction pour supprimer un commentaire (seul l'auteur peut le supprimer)
    function deleteComment(uint _postId, uint _commentIndex) public {
        require(_postId < posts.length, "Post does not exist");
        require(posts[_postId].exists, "Post has been deleted");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");
        require(postComments[_postId][_commentIndex].exists, "Comment has already been deleted");
        require(postComments[_postId][_commentIndex].commenter == msg.sender, "You are not the author of this comment");

        postComments[_postId][_commentIndex].exists = false;
        postComments[_postId][_commentIndex].likeCount = 0;
    }

    // Fonction pour récupérer un post par index
    function getPost(uint _postId) public view returns (string memory, address, uint, uint, bool) {
        require(_postId < posts.length, "Post does not exist");
        Post storage post = posts[_postId];
        return (post.message, post.author, post.likeCount, post.commentCount, post.exists);
    }

    // Fonction pour récupérer un commentaire par index d'un post
    function getComment(uint _postId, uint _commentIndex) public view returns (string memory, address, uint, bool) {
        require(_postId < posts.length, "Post does not exist");
        require(_commentIndex < postComments[_postId].length, "Comment does not exist");

        Comment storage comment = postComments[_postId][_commentIndex];
        return (comment.message, comment.commenter, comment.likeCount, comment.exists);
    }

    // Fonction pour obtenir le nombre total de posts
    function getTotalPosts() public view returns (uint) {
        return posts.length;
    }

    // Fonction pour obtenir le nombre total de commentaires sur un post
    function getTotalComments(uint _postId) public view returns (uint) {
        require(_postId < posts.length, "Post does not exist");
        return postComments[_postId].length;
    }

    // Fonction pour obtenir le nombre total de likes sur un post
    function getPostLikes(uint _postId) public view returns (uint) {
        require(_postId < posts.length, "Post does not exist");
        return posts[_postId].likeCount;
    }
}
