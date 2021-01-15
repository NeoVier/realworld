import {
  Column,
  Entity,
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

  @ManyToMany(() => Article)
  favorited: Article[];

  @ManyToMany(() => User)
  followers: User[];

  @OneToMany(() => Comment, (comment) => comment.author)
  comments: Comment[];
}

export default User;
