import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import Article from "./Article";
import Comment from "./Comment";

@Entity()
class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  email: string;

  @Column()
  username: string;

  @Column()
  bio: string;

  @Column({ nullable: true })
  image: string;

  @OneToMany(() => Article, (article) => article.author)
  articles: Article[];

  @ManyToMany(() => Article, (article) => article.favorited)
  favorited: Article[];

  @ManyToMany(() => User, (user) => user.follows)
  followedBy: User[];

  @ManyToMany(() => User, (user) => user.followedBy)
  @JoinTable()
  follows: User[];

  @OneToMany(() => Comment, (comment) => comment.author)
  comments: Comment[];
}

export default User;
